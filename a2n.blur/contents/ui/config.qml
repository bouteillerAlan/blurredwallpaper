/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2019 David Redondo <kde@david-redondo.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QtControls2
import QtQuick.Layouts
import org.kde.plasma.wallpapers.image as PlasmaWallpaper
import org.kde.kquickcontrols as KQuickControls
import org.kde.kquickcontrolsaddons
import org.kde.newstuff as NewStuff
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

/**
 * For proper alignment, an ancestor **MUST** have id "appearanceRoot" and property "parentLayout"
 */
ColumnLayout {
    id: root

    property var configDialog
    property var wallpaperConfiguration: wallpaper.configuration
    property var parentLayout
    property var screenSize: Qt.size(Screen.width, Screen.height)

    property alias cfg_Color: colorButton.color
    property color cfg_ColorDefault
    property string cfg_Image
    property string cfg_ImageDefault
    property int cfg_FillMode
    property int cfg_FillModeDefault
    property int cfg_SlideshowMode
    property int cfg_SlideshowModeDefault
    property bool cfg_SlideshowFoldersFirst
    property bool cfg_SlideshowFoldersFirstDefault: false
    property alias cfg_Blur: blurRadioButton.checked
    property bool cfg_BlurDefault
    property var cfg_SlidePaths: []
    property var cfg_SlidePathsDefault: []
    property int cfg_SlideInterval: 0
    property int cfg_SlideIntervalDefault: 0
    property var cfg_UncheckedSlides: []
    property var cfg_UncheckedSlidesDefault: []

    // custom property for the active blur effect
    property alias cfg_ActiveBlur: activeBlurRadioButton.checked
    property int cfg_AnimationDuration: 400
    property int cfg_BlurRadius: 40
    property alias cfg_ActiveColor: activeColorRadioButton.checked
    property int cfg_ActiveColorTransparency: 20
    property alias cfg_ActiveColorColor: activeColorColorButton.color
    property alias cfg_IsSlideshow: activeSlideshowRadioButton.checked

    signal configurationChanged()
    /**
     * Emitted when the user finishes adding images using the file dialog.
     */
    signal wallpaperBrowseCompleted();

    onScreenSizeChanged: function() {
        if (thumbnailsLoader.item) {
            thumbnailsLoader.item.screenSize = root.screenSize;
        }
    }

    function saveConfig() {
        if (configDialog.currentWallpaper === "org.kde.image") {
            imageWallpaper.wallpaperModel.commitAddition();
            imageWallpaper.wallpaperModel.commitDeletion();
        }
        wallpaperConfiguration.PreviewImage = "null"; // internal, no need to save to file
    }

    function openChooserDialog() {
        const dialogComponent = Qt.createComponent("AddFileDialog.qml");
        dialogComponent.createObject(root);
        dialogComponent.destroy();
    }

    PlasmaWallpaper.ImageBackend {
        id: imageWallpaper
        renderingMode: (!cfg_IsSlideshow) ? PlasmaWallpaper.ImageBackend.SingleImage : PlasmaWallpaper.ImageBackend.SlideShow
        targetSize: {
            // Lock screen configuration case
            return Qt.size(root.screenSize.width * Screen.devicePixelRatio, root.screenSize.height * Screen.devicePixelRatio)
        }
        onSlidePathsChanged: cfg_SlidePaths = slidePaths
        onUncheckedSlidesChanged: cfg_UncheckedSlides = uncheckedSlides
        onSlideshowModeChanged: cfg_SlideshowMode = slideshowMode
        onSlideshowFoldersFirstChanged: cfg_SlideshowFoldersFirst = slideshowFoldersFirst

        onSettingsChanged: root.configurationChanged()
    }

    onCfg_FillModeChanged: {
        resizeComboBox.setMethod()
    }

    onCfg_SlidePathsChanged: {
        if (cfg_SlidePaths)
            imageWallpaper.slidePaths = cfg_SlidePaths
    }
    onCfg_UncheckedSlidesChanged: {
        if (cfg_UncheckedSlides)
            imageWallpaper.uncheckedSlides = cfg_UncheckedSlides
    }

    onCfg_SlideshowModeChanged: {
        if (cfg_SlideshowMode)
            imageWallpaper.slideshowMode = cfg_SlideshowMode
    }

    onCfg_SlideshowFoldersFirstChanged: {
        if (cfg_SlideshowFoldersFirst)
            imageWallpaper.slideshowFoldersFirst = cfg_SlideshowFoldersFirst
    }

    spacing: 0

    Kirigami.FormLayout {
        id: formLayout

        Layout.bottomMargin: !cfg_IsSlideshow ? Kirigami.Units.largeSpacing : 0

        Component.onCompleted: function() {
            if (typeof appearanceRoot !== "undefined") {
                twinFormLayouts.push(appearanceRoot.parentLayout);
            }
        }

        QtControls2.ComboBox {
            id: resizeComboBox
            Kirigami.FormData.label: i18ndc("plasma_wallpaper_org.kde.image", "@label:listbox", "Positioning:")
            model: [
                        {
                            'label': i18ndc("plasma_wallpaper_org.kde.image", "@item:inlistbox", "Scaled and cropped"),
                            'fillMode': Image.PreserveAspectCrop
                        },
                        {
                            'label': i18ndc("plasma_wallpaper_org.kde.image", "@item:inlistbox", "Scaled"),
                            'fillMode': Image.Stretch
                        },
                        {
                            'label': i18ndc("plasma_wallpaper_org.kde.image", "@item:inlistbox", "Scaled, keep proportions"),
                            'fillMode': Image.PreserveAspectFit
                        },
                        {
                            'label': i18ndc("plasma_wallpaper_org.kde.image", "@item:inlistbox", "Centered"),
                            'fillMode': Image.Pad
                        },
                        {
                            'label': i18ndc("plasma_wallpaper_org.kde.image", "@item:inlistbox", "Tiled"),
                            'fillMode': Image.Tile
                        }
            ]

            textRole: "label"
            onActivated: cfg_FillMode = model[currentIndex]["fillMode"]
            Component.onCompleted: setMethod();

            KCM.SettingHighlighter {
                highlight: cfg_FillModeDefault != cfg_FillMode
            }

            function setMethod() {
                for (var i = 0; i < model.length; i++) {
                    if (model[i]["fillMode"] === root.cfg_FillMode) {
                        resizeComboBox.currentIndex = i;
                        break;
                    }
                }
            }
        }

        QtControls2.ButtonGroup { id: backgroundGroup }

        QtControls2.RadioButton {
            id: blurRadioButton
            visible: cfg_FillMode === Image.PreserveAspectFit || cfg_FillMode === Image.Pad
            Kirigami.FormData.label: i18nd("plasma_wallpaper_org.kde.image", "Background:")
            text: i18nd("plasma_wallpaper_org.kde.image", "Blur")
            QtControls2.ButtonGroup.group: backgroundGroup
        }

        RowLayout {
            id: colorRow
            visible: cfg_FillMode === Image.PreserveAspectFit || cfg_FillMode === Image.Pad
            QtControls2.RadioButton {
                id: colorRadioButton
                text: i18nd("plasma_wallpaper_org.kde.image", "Solid color")
                checked: !cfg_Blur
                QtControls2.ButtonGroup.group: backgroundGroup

                KCM.SettingHighlighter {
                    highlight: cfg_Blur != cfg_BlurDefault
                }
            }
            KQuickControls.ColorButton {
                id: colorButton
                color: cfg_Color
                dialogTitle: i18nd("plasma_wallpaper_org.kde.image", "Select Background Color")

                KCM.SettingHighlighter {
                    highlight: cfg_Color != cfg_ColorDefault
                }
            }
        }

        // on/off button for slideshow
        QtControls2.CheckBox {
            id: activeSlideshowRadioButton
            visible: true
            Kirigami.FormData.label: "Slideshow:"
            text: activeSlideshowRadioButton.checked ? "On" : "Off"
            onCheckedChanged: {
                root.slideshowStateChanged(activeSlideshowRadioButton.checked);
                alertIsSlideshowChanged.visible = true;
            }
        }

        Kirigami.InlineMessage {
            id: alertIsSlideshowChanged
            Layout.fillWidth: true
            text: "Please hit Apply and reopen this window before doing anything else. <br> <a href=\"https://github.com/bouteillerAlan/blurredwallpaper/issues/25\">If you want to help with this issue, click here!<a/>"
            onLinkActivated: Qt.openUrlExternally(link)
            type: Kirigami.MessageType.Error
        }

        // on/off button for active blur
        QtControls2.CheckBox {
            id: activeBlurRadioButton
            visible: true
            Kirigami.FormData.label: "Active Blur:"
            text: activeBlurRadioButton.checked ? "On" : "Off"
        }

        // slider for the active blur radius
        QtControls2.SpinBox {
            Kirigami.FormData.label: "Blur Radius:"
            id: blurRadiusSpinBox
            value: cfg_BlurRadius
            onValueChanged: cfg_BlurRadius = value
            stepSize: 1
            from: 1
            to: 9999
            editable: true
            enabled: activeBlurRadioButton.checked
        }

        Kirigami.InlineMessage {
            id: blurRadiusWarning
            Layout.fillWidth: true
            text: "The value ranges from 0 to 9999. Visual quality of the blur is reduced when radius exceeds value 64 due to QT. Some high value may blackout your wallpaper. If this is the case, reduce the value until normal behavior is restored."
            type: Kirigami.MessageType.Information
            visible: blurRadiusSpinBox.value > 64
        }

        // on/off button for active color
        QtControls2.CheckBox {
          id: activeColorRadioButton
          visible: true
          Kirigami.FormData.label: "Active Color:"
          text: activeColorRadioButton.checked ? "On" : "Off"
        }

        QtControls2.SpinBox {
          Kirigami.FormData.label: "Color transparency:"
          id: colorTransparencySpinBox
          value: cfg_ActiveColorTransparency
          onValueChanged: cfg_ActiveColorTransparency = value
          stepSize: 1
          from: 0
          to: 100
          editable: true
          enabled: activeColorRadioButton.checked
        }

        KQuickControls.ColorButton {
          id: activeColorColorButton
          Kirigami.FormData.label: "Color: "
          enabled: activeColorRadioButton.checked
        }


        // slider for the active blur animation delay
        QtControls2.SpinBox {
            Kirigami.FormData.label: "Animation Delay:"
            id: animationDurationSpinBox
            value: cfg_AnimationDuration
            onValueChanged: cfg_AnimationDuration = value
            from: 0
            to: 60000 // 1 minute in ms
            stepSize: 50
            editable: true
            enabled: activeBlurRadioButton.checked || activeColorRadioButton.checked

            textFromValue: function(value, locale) {
                return i18n("%1ms", value)
            }

            valueFromText: function(text, locale) {
                return parseInt(text, 10)
            }
        }

    }

    DropArea {
        Layout.fillWidth: true
        Layout.fillHeight: true

        onEntered: drag => {
            if (drag.hasUrls) {
                drag.accept();
            }
        }
        onDropped: drop => {
            drop.urls.forEach(function (url) {
                if (!cfg_IsSlideshow) {
                    imageWallpaper.addUsersWallpaper(url);
                } else {
                    imageWallpaper.addSlidePath(url);
                }
            });
            // Scroll to top to view added images
            if (!cfg_IsSlideshow) {
                thumbnailsLoader.item.view.positionViewAtIndex(0, GridView.Beginning);
            }
        }

        Loader {
            id: thumbnailsLoader
            anchors.fill: parent

            function loadWallpaper () {
                let source = (!cfg_IsSlideshow) ? "ThumbnailsComponent.qml" :
                    ((cfg_IsSlideshow) ? "SlideshowComponent.qml" : "");

                let props = {screenSize: screenSize};

                if (cfg_IsSlideshow) {
                    props["configuration"] = wallpaperConfiguration;
                }

                thumbnailsLoader.setSource(source, props);
            }
        }

        Connections {
            target: configDialog
            function onCurrentWallpaperChanged() {
                thumbnailsLoader.loadWallpaper();
            }
        }

        Connections {
            target: root
            function onSlideshowStateChanged(isChecked) {
                console.log("IsSlideshow state changed:", isChecked);
                // reload the UI, but not the img list
                thumbnailsLoader.loadWallpaper();
            }
        }

        Component.onCompleted: () => {
            thumbnailsLoader.loadWallpaper();
        }

    }

    Component.onDestruction: {
        if (wallpaperConfiguration)
            wallpaperConfiguration.PreviewImage = "null";
    }
}
