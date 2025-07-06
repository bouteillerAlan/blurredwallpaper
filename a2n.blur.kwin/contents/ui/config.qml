import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property int cfg_ActiveBlur
    property int cfg_BlurRadius
    property int cfg_AnimationDuration

    ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        CheckBox {
            id: activeBlurCheckbox
            text: i18n("Enable blur effect")
            checked: cfg_ActiveBlur
            onCheckedChanged: cfg_ActiveBlur = checked ? 1 : 0
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Item {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Blur Settings")
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Blur radius:")

                Slider {
                    id: blurRadiusSlider
                    Layout.fillWidth: true
                    from: 1
                    to: 100
                    stepSize: 1
                    value: cfg_BlurRadius
                    onValueChanged: cfg_BlurRadius = value
                    enabled: activeBlurCheckbox.checked
                }

                SpinBox {
                    id: blurRadiusSpinBox
                    from: 1
                    to: 100
                    stepSize: 1
                    value: cfg_BlurRadius
                    onValueChanged: cfg_BlurRadius = value
                    enabled: activeBlurCheckbox.checked
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Animation duration (ms):")

                Slider {
                    id: animationDurationSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1000
                    stepSize: 10
                    value: cfg_AnimationDuration
                    onValueChanged: cfg_AnimationDuration = value
                    enabled: activeBlurCheckbox.checked
                }

                SpinBox {
                    id: animationDurationSpinBox
                    from: 0
                    to: 1000
                    stepSize: 10
                    value: cfg_AnimationDuration
                    onValueChanged: cfg_AnimationDuration = value
                    enabled: activeBlurCheckbox.checked
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        // Convert boolean to int for the checkbox
        cfg_ActiveBlur = cfg_ActiveBlur ? 1 : 0;
    }
}
