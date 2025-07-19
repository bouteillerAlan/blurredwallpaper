package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

const (
	Reset  = "\033[0m"
	Red    = "\033[31m"
	Green  = "\033[32m"
	Yellow = "\033[33m"
	Blue   = "\033[34m"
)

type LogType string

const (
	Error   LogType = "error"
	Warning LogType = "warning"
	Success LogType = "success"
	Info    LogType = "info"
)

type CopyProgress struct {
	TotalFiles  int
	CopiedFiles int
	TotalSize   int64
	CopiedSize  int64
}

type Metadata struct {
	KPlugin struct {
		ID string `json:"Id"`
	} `json:"KPlugin"`
}

// wallpaper applet related flags
var installWallpaper = flag.Bool("w", false, "Install wallpaper plugin")
var wallpaperSource = flag.String("ws", "a2n.blur", "Wallpaper source folder (absolute path)")
var wallpaperTarget = flag.String("wt", "/home/a2n/.local/share/plasma/wallpapers/a2n.blur", "Wallpaper target folder (absolute path)")

// kwin-script related flags
var installKwinScript = flag.Bool("k", false, "Pack and install kwin script")
var kwinScriptSource = flag.String("ks", "a2n.blur.ks/a2n.windowSignal", "kwinScript source folder (absolute path)")

// qol related flags
var restart = flag.Bool("r", false, "Restart plasma after install")
var showJournalctl = flag.Bool("j", false, "Show journalctl output")

// Executes a command with given arguments
// Parameters:
//   - cmd: the command string to execute
//
// Returns the output as a string and an error if any occurs
func execCmd(cmd string) (string, error) {
	var compatCmd *exec.Cmd

	switch runtime.GOOS {
	case "windows":
		compatCmd = exec.Command("cmd", "/C", cmd)
	default:
		compatCmd = exec.Command("sh", "-c", cmd)
	}
	out, err := compatCmd.Output()
	return string(out), err
}

// logs a message to the console with a specified log type and applies corresponding formatting
// Parameters:
//   - logType: is one value of LogType and determines the format of the log
//   - message: the string you want to print
//   - stopIfError: default to true, hard stop the script if true and error log is triggered
func log(logType LogType, message string, stopIfError ...bool) {
	switch strings.ToLower(string(logType)) {
	case string(Error):
		fmt.Printf("%s%s%s\n", Red, message, Reset)
	case string(Warning):
		fmt.Printf("%s%s%s\n", Yellow, message, Reset)
	case string(Success):
		fmt.Printf("%s%s%s\n", Green, message, Reset)
	case string(Info):
		fmt.Printf("%s%s%s\n", Blue, message, Reset)
	default:
		fmt.Printf("%s\n", message)
	}

	stop := true
	if len(stopIfError) > 0 {
		stop = stopIfError[0]
	}
	if stop && logType == Error {
		os.Exit(1)
	}
}

// copies a file from the provided source path to the destination path
// It preserves file permissions of the source file at the destination
// Parameters:
//   - src: source string path
//   - dst: destination string path
//
// Returns an error if the operation fails at any step
func copyFile(src string, dst string) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer func(srcFile *os.File) {
		err := srcFile.Close()
		if err != nil {
			log(Error, fmt.Sprintf("Failed to close file: %v", err))
		}
	}(srcFile)

	dstFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer func(dstFile *os.File) {
		err := dstFile.Close()
		if err != nil {
			log(Error, fmt.Sprintf("Failed to close file: %v", err))
		}
	}(dstFile)

	_, err = io.Copy(dstFile, srcFile)
	if err != nil {
		return err
	}

	// Copy file permissions
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	return os.Chmod(dst, srcInfo.Mode())
}

// copies the contents of the source folder to the destination folder recursively
// It calculates and sends copy progress via the provided progress channel
// Parameters:
//   - src: source folder path
//   - dst: destination folder path
//   - progress: a channel to send CopyProgress updates
//
// Returns an error if the operation fails at any step.
func copyFolder(src string, dst string, progress chan<- CopyProgress) error {
	// First pass: count files and size
	var totalFiles int
	var totalSize int64

	err := filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() {
			totalFiles++
			totalSize += info.Size()
		}
		return nil
	})

	if err != nil {
		return err
	}

	// Create destination folder
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	err = os.MkdirAll(dst, srcInfo.Mode())
	if err != nil {
		return err
	}

	// Second pass: copy files
	var copiedFiles int
	var copiedSize int64

	return filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		relPath, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}

		dstPath := filepath.Join(dst, relPath)

		if info.IsDir() {
			return os.MkdirAll(dstPath, info.Mode())
		}

		// Copy file
		err = copyFile(path, dstPath)
		if err != nil {
			return err
		}

		// Update progress
		copiedFiles++
		copiedSize += info.Size()

		if progress != nil {
			progress <- CopyProgress{
				TotalFiles:  totalFiles,
				CopiedFiles: copiedFiles,
				TotalSize:   totalSize,
				CopiedSize:  copiedSize,
			}
		}

		return nil
	})
}

// package, installs and enables a KWin script, then reloads KWin for the changes to take effect
func launchInstallKwinScript() {
	log(Info, "Installing kwin script")

	log(Info, "Uninstall old kwin script")
	metadataPath := filepath.Join(*kwinScriptSource, "metadata.json")
	data, err := os.ReadFile(metadataPath)
	if err != nil {
		log(Error, fmt.Sprintf("Failed to read metadata.json: %v", err))
	}
	var metadata Metadata
	err = json.Unmarshal(data, &metadata)
	if err != nil {
		log(Error, fmt.Sprintf("Failed to parse metadata.json: %v", err))
	}
	if _, err := execCmd("kpackagetool6 --type=KWin/Script -r " + metadata.KPlugin.ID); err != nil {
		log(Error, fmt.Sprintf("Failed to uninstall kwinScript: %v", err), false)
	}

	log(Info, "Package kwin script")
	srcPath := filepath.Dir(*kwinScriptSource)
	parentDir := filepath.Base(srcPath)
	distPath := filepath.Join(parentDir, "dist")
	outputFile := filepath.Join(distPath, metadata.KPlugin.ID+".kwinscript")
	if _, err := execCmd("zip -r " + outputFile + " " + *kwinScriptSource); err != nil {
		log(Error, fmt.Sprintf("Failed to package kwinScript: %v", err))
	}

	// fixme: the check and reload dosent work atm
	log(Info, "Enable kwin script")
	if _, err := execCmd("kwriteconfig6 --file kwinrc --group Plugins --key " + metadata.KPlugin.ID + "Enabled true"); err != nil {
		log(Error, fmt.Sprintf("Failed to enable kwinScript: %v", err))
	}

	log(Info, "Reload kwin")
	if _, err := execCmd("qdbus6 org.kde.KWin /KWin reconfigure"); err != nil {
		log(Error, fmt.Sprintf("Failed to reload kwin: %v", err))
	}

	log(Success, "Successfully installed kwinScript")
}

// restarts the Plasma shell by stopping and starting it using system commands
func launchRestartPlasma() {
	log(Info, "Restarting plasma")
	if _, err := execCmd("kquitapp6 plasmashell && kstart plasmashell"); err != nil {
		log(Error, "Failed to restart plasma "+err.Error())
	}
	log(Success, "Successfully restarted plasma")
}

// displays the user-specific journalctl log output with live update
func launchJournal() {
	log(Info, "Showing journalctl (user only) output")
	if _, err := execCmd("journalctl --user -f"); err != nil {
		log(Error, "Failed to show the journal "+err.Error())
	}
	log(Success, "Successfully showed the journalctl output")
}

// installs the wallpaper plugin
func launchInstallWallpaper() {
	log(Info, "Installing wallpaper plugin")
	progress := make(chan CopyProgress)

	// Start copy in goroutine
	go func() {
		err := copyFolder(*wallpaperSource, *wallpaperTarget, progress)
		if err != nil {
			log(Error, fmt.Sprintf("Failed to copy wallpaper: %v", err))
		}
		close(progress)
	}()

	// Monitor progress
	for p := range progress {
		fmt.Printf("Progress: %d/%d files (%.1f%%) - %.1f MB/%.1f MB\n",
			p.CopiedFiles, p.TotalFiles,
			float64(p.CopiedFiles)/float64(p.TotalFiles)*100,
			float64(p.CopiedSize)/1024/1024,
			float64(p.TotalSize)/1024/1024)
	}
	log(Success, "Successfully installed wallpaper plugin")
}

func main() {
	flag.Parse()

	if *installWallpaper {
		launchInstallWallpaper()
	}

	if *installKwinScript {
		launchInstallKwinScript()
	}

	if *restart {
		launchRestartPlasma()
	}

	// fixme: dosent work
	//if *showJournalctl {
	//	launchJournal()
	//}
}
