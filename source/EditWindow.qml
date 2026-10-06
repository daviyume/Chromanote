import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

//EDIT WINDOW
ApplicationWindow {
    id: editwindow
    title: themename
    width: 800
    height: 680
    minimumWidth: 640
    minimumHeight: 450
    palette{
        id: editwindowpalette
        window: "#0000FF"
    }
    font.family: Qt.application.font.family

    property font pselfont;
    property int pfillmode: fillmode;

    onVisibilityChanged: {
        editname.text = themename
        edittextcolor.text = textcolor
        editbgcolor.text = bgcolor
        editnotecolor.text = notecolor
        editnotebordercolor.text = notebordercolor
        editbuttoncolor.text = buttoncolor
        pselfont = selfont

        editbg.text = bg
        editnotetexture.text = notetexture
        pfillmode = fillmode
        opacityslider.value = notetextureopacity
        editshinecolor.text = shinecolor
    }

    //PREVIEW
    Rectangle{
        id: preview
        x: 5
        y: 5
        width: editwindow.width*0.66
        height: editwindow.height*0.5

        color: editbgcolor.text
        clip:true

        //border
        Rectangle{
            width: preview.width; height: preview.height
            color: "#00000000"
            border.color: "#AAAAAA"
            border.width: 2
            z: 1
        }

        //bg
        Loader{
            active: app.checkValidPath(editbg.text)
            sourceComponent: Image {
                width: editwindow.width*0.66
                height: editwindow.height*0.5
                source: editbg.text;

                fillMode: editwindow.pfillmode
                verticalAlignment: Image.AlignTop;
                horizontalAlignment: Image.AlignLeft
            }
        }

        Rectangle { //box
            id: pnoteblock
            x: preview.width*0.2
            y: preview.height*0.2
            width: preview.width*0.25
            height: width

            Rectangle{
                id: pborder
                width: parent.width
                height: width
                border.color: editnotebordercolor.text
                border.width: 2
                color: "#00000000"
                z: 1
            }

            gradient: Gradient{
                GradientStop {position: -0.25; color: editshinecolor.text}
                GradientStop {position: 0.5; color: editnotecolor.text}
            }

            Loader{
                active: app.checkValidPath(editnotetexture.text)
                sourceComponent: Image {
                    source: editnotetexture.text || ""
                    fillMode: Image.Stretch
                    width: pnoteblock.width
                    height: width
                    opacity: opacityslider.value
                }
            }

            Label{
                x: 4
                y: 4
                width: parent.width
                height: parent.height
                color: edittextcolor.text
                text: "This is how the theme will look."
                font: editwindow.pselfont

                fontSizeMode: Text.Fit
                wrapMode: Text.WordWrap
            }
        }

        QButton{
            x: preview.width*0.6
            y: preview.height*0.2
            width: 100
            height: 26
            text: "Button"
            palette.buttonText: edittextcolor.text
            palette.button: editbuttoncolor.text

            font: editwindow.pselfont
        }

    }

    //LEFT COLUMN
    ScrollView{
        id: leftscroll
        x: 10
        y: editwindow.height*0.5 + 35
        width: editwindow.width*0.66 + 5
        height: editwindow.height - y
        clip: true

        ColumnLayout{
            id: leftcolumn
            palette: editwindowpalette

            spacing: 5
            width: parent.width

            Label{text: "Font"}

            //editfont holds family name only.
            //advanced holds full font name only.
            //pselfont holds full font and updates based on the previous two.
            //fontstring holds pselfont so it can be inserted in the file and read properly from there (without QFont writings).

            ComboBox{
                id: editfont
                Layout.preferredWidth: leftscroll.width*0.75
                Layout.preferredHeight: 30
                model: app.loadFonts()
                displayText: editwindow.pselfont.family
                font.family: editwindow.pselfont.family
                currentIndex: editfont.find(pselfont.family)
                Layout.bottomMargin: 5

                Component.onCompleted: {
                    editfont.currentIndex = editfont.find(selfont.family)
                }

                delegate: ItemDelegate { //delegates each font item so that each item can have its own font and properties and they don't have to share everything
                    width: 240
                    height: 30
                    Label {
                        text: modelData
                        font.family: modelData
                        font.pixelSize: 14
                    }
                }
                onCurrentTextChanged: {
                    if(editwindow.visibility === Window.Hidden)
                        return;
                    editwindow.pselfont.family = currentText
                }

                QButton{
                    id: advancedfont
                    anchors.left: editfont.right
                    text: "Advanced"
                    Layout.bottomMargin: 5
                    stylecolor: palette.button
                    font: Qt.application.font

                    onClicked: {
                        fontdial.open()
                    }
                }
            }

            FontDialog{
                options: FontDialog.DontUseNativeDialog
                id: fontdial
                selectedFont: editwindow.pselfont

                onAccepted: {
                    editwindow.pselfont = selectedFont
                }
            }

            Label{text: "Background Image"}
            TextField{
                id: editbg
                Layout.bottomMargin: 5
                Layout.preferredWidth: leftscroll.width*0.75

                text: bg

                onAccepted: {
                    app.writeTheme(seltheme, 4, editbuttoncolor.text)
                    bg = editbuttoncolor.text
                }
                QButton{
                    anchors.left: editbg.right
                    text: "File"
                    stylecolor: palette.button
                    onClicked:{
                        bgfiledialog.open();
                    }
                }
            }

            FileDialog{
                id: bgfiledialog
                Component.onCompleted: {
                    if(app.checkValidPath(bg))
                    selectedFile = bg
                }
                onAccepted: {
                    var cleanpath = selectedFile.toString().replace("file://", "")
                    console.log(selectedFile)

                    app.writeTheme(seltheme, 4, selectedFile)
                    editbg.text = selectedFile
                }
            }

            Rectangle{
                id: bgradio
                height: 30
                property bool valid: app.checkValidPath(editbg.text)

                ButtonGroup{id: fillmodeselection}
                RadioButton{
                    x: 20
                    width: 100
                    ButtonGroup.group: fillmodeselection
                    text: "fit" //2
                    checked: editwindow.pfillmode===Image.PreserveAspectCrop
                    onCheckedChanged: {
                        if(checked)
                            editwindow.pfillmode=Image.PreserveAspectCrop;
                    }
                    enabled: bgradio.valid
                    opacity: enabled? 1:0.2
                }
                RadioButton{
                    x: 120
                    width: 100
                    ButtonGroup.group: fillmodeselection
                    text: "tile" //3
                    checked: editwindow.pfillmode===Image.Tile
                    onCheckedChanged: {
                        if(checked)
                            editwindow.pfillmode=Image.Tile;
                    }
                    enabled: bgradio.valid
                    opacity: enabled? 1:0.2
                }
                RadioButton{
                    x: 220
                    width: 100
                    ButtonGroup.group: fillmodeselection
                    text: "stretch" //0
                    checked: editwindow.pfillmode===Image.Stretch
                    onCheckedChanged: {
                        if(checked)
                            editwindow.pfillmode=Image.Stretch;
                    }
                    enabled: bgradio.valid
                    opacity: enabled? 1:0.2
                }
            }

            Label{text: "Note texture Image"}
            TextField{
                id: editnotetexture
                Layout.bottomMargin: 5
                Layout.preferredWidth: leftscroll.width*0.75
                text: notetexture

                onAccepted: {
                    app.writeTheme(seltheme, 4, editnotetexture.text)
                    bg = editnotetexture.text
                }
                QButton{
                    anchors.left: editnotetexture.right
                    text: "File"
                    stylecolor: palette.button
                    onClicked:{
                        notetexturefiledialog.open();
                    }
                }
            }

            FileDialog{
                id: notetexturefiledialog

                Component.onCompleted: {
                    if(app.checkValidPath(editnotetexture.text))
                    selectedFile = editnotetexture.text
                }
                onAccepted: {
                    var cleanpath = selectedFile.toString().replace("file://", "")
                    console.log(selectedFile)

                    app.writeTheme(seltheme, 6, selectedFile)
                    editnotetexture.text = selectedFile
                }
            }


            Label{text: "texture opacity ("+parseInt(opacityslider.value*100)+")"; opacity: opacityslider.enabled? 1 : 0.2}
            Slider {
                id: opacityslider
                from: 0
                value: notetextureopacity
                to: 1
                enabled: app.checkValidPath(editnotetexture.text)
                opacity: enabled? 1 : 0.2
            }

        }
    }

    //RIGHT COLUMN
    ScrollView{
        x: editwindow.width*0.66 + 5
        y: 10
        width: editwindow.width*0.33
        height: editwindow.height

        ColumnLayout{
            id: rightcolumn
            x: 32

            spacing: 5

            Label{text: "Theme name"}
            TextField{
                id: editname
                Layout.bottomMargin: 5

                Component.onCompleted:{text = themename} //MAKE BIND?
            }

            Label{text: "Text color"}
            TextField{
                id: edittextcolor
                Layout.bottomMargin: 5

                Component.onCompleted:{text = textcolor}

                Button{
                    anchors.left: edittextcolor.right
                    background: Rectangle{color: edittextcolor.text; border.color: "#FFFFFF"; border.width: 2}
                    width: 26
                    height: width
                    property int pos: 3;
                    onClicked: {
                        var cdinstance = colordialogcomp.createObject(editwindow, {"pos": pos});
                        cdinstance.open()
                    }
                }
            }

            Label{text: "Background color"}
            TextField{
                id: editbgcolor
                Layout.bottomMargin: 5

                Component.onCompleted: {text = bgcolor}

                Button{
                    anchors.left: editbgcolor.right
                    background: Rectangle{color: editbgcolor.text; border.color: "#FFFFFF"; border.width: 2}
                    width: 26
                    height: width
                    property int pos: 5;
                    onClicked: {
                        var cdinstance = colordialogcomp.createObject(editwindow, {"pos": pos});
                        cdinstance.open()
                    }
                }
            }

            Label{text: "Note color"}
            TextField{
                id: editnotecolor
                Layout.bottomMargin: 5

                Component.onCompleted: {text = notecolor}

                Button{
                    anchors.left: editnotecolor.right
                    background: Rectangle{color: editnotecolor.text; border.color: "#FFFFFF"; border.width: 2}
                    width: 26
                    height: width
                    property int pos: 7;
                    onClicked: {
                        var cdinstance = colordialogcomp.createObject(editwindow, {"pos": pos});
                        cdinstance.open()
                    }
                }
            }

            Label{text: "Note border color"}
            TextField{
                id: editnotebordercolor
                Layout.bottomMargin: 5

                Component.onCompleted:{text = notebordercolor}

                Button{
                    anchors.left: editnotebordercolor.right
                    background: Rectangle{color: editnotebordercolor.text; border.color: "#FFFFFF"; border.width: 2}
                    width: 26
                    height: width
                    property int pos: 8;
                    onClicked: {
                        var cdinstance = colordialogcomp.createObject(editwindow, {"pos": pos});
                        cdinstance.open()
                    }
                }
            }

            Label{text: "Button color"}
            TextField{
                id: editbuttoncolor
                Layout.bottomMargin: 5

                Component.onCompleted:{text = buttoncolor}

                Button{
                    anchors.left: editbuttoncolor.right
                    background: Rectangle{color: editbuttoncolor.text; border.color: "#FFFFFF"; border.width: 2}
                    width: 26
                    height: width
                    property int pos: 9;
                    onClicked: {
                        var cdinstance = colordialogcomp.createObject(editwindow, {"pos": pos});
                        cdinstance.open()
                    }
                }
            }

            Label{text: "Shine color"}
            TextField{
                id: editshinecolor
                Layout.bottomMargin: 5

                Component.onCompleted:{text = shinecolor}

                Button{
                    anchors.left: editshinecolor.right
                    background: Rectangle{color: editshinecolor.text; border.color: "#FFFFFF"; border.width: 2}
                    width: 26
                    height: width
                    property int pos: 12;
                    onClicked: {
                        var cdinstance = colordialogcomp.createObject(editwindow, {"pos": pos});
                        cdinstance.open()
                    }
                }
            }

        }

        Component{
            id:colordialogcomp
            ColorDialog {
                    property int pos;
                    id: colordialog
                    title: "Select a color"
                    selectedColor: retrieveColor(pos)
                    options: ColorDialog.ShowAlphaChannel
                    parentWindow: editwindow

                    onAccepted: {
                        chooseColor(pos);
                    }

                    function retrieveColor(pos)
                    {
                        switch(pos)
                        {
                            case 3: return edittextcolor.text;
                            case 5: return editbgcolor.text;
                            case 7: return editnotecolor.text;
                            case 8: return editnotebordercolor.text;
                            case 9: return editbuttoncolor.text;
                            case 12: return  editshinecolor.text;
                        }
                    }
                    function chooseColor(pos)
                    {
                        switch(pos)
                        {
                            case 3: edittextcolor.text = selectedColor;
                                break;
                            case 5: editbgcolor.text = selectedColor;
                                break;
                            case 7: editnotecolor.text = selectedColor;
                                break;
                            case 8: editnotebordercolor.text = selectedColor;
                                break;
                            case 9: editbuttoncolor.text = selectedColor;
                                break;
                            case 12: editshinecolor.text = selectedColor;
                        }
                    }

            }
        }

    }

    //EXIT
    QButton{
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20
        anchors.rightMargin: 140
        width: 80

        text: "Exit"
        stylecolor: palette.button

        onClicked:{
            optionswindow.show();
            editwindow.close();
        }
    }

    //SAVE
    QButton{
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20
        anchors.rightMargin: 40
        width: 80

        text: "Save"

        property int themetorefresh;
        property string fontstring: editwindow.pselfont;
        onClicked:
        {
            app.writeTheme(seltheme, 1, editname.text);
            app.writeTheme(seltheme, 2, fontstring);
            app.writeTheme(seltheme, 3, edittextcolor.text);
            app.writeTheme(seltheme, 4, editbg.text);
            app.writeTheme(seltheme, 5, editbgcolor.text);
            app.writeTheme(seltheme, 6, editnotetexture.text);
            app.writeTheme(seltheme, 7, editnotecolor.text);
            app.writeTheme(seltheme, 8, editnotebordercolor.text);
            app.writeTheme(seltheme, 9, editbuttoncolor.text);
            app.writeTheme(seltheme, 10, editwindow.pfillmode);
            app.writeTheme(seltheme, 11, opacityslider.value);
            app.writeTheme(seltheme, 12, editshinecolor.text);
            thememodelReload(seltheme);
            themetorefresh = seltheme;
            seltheme = -1; //update all variables binded to seltheme
            seltheme = themetorefresh;
        }
    }

    Rectangle{width:4; height: editwindow.height; color: "#444444"; anchors.right: parent.right}
    Rectangle{width:editwindow.width; height: 4; color: "#444444"; anchors.bottom: parent.bottom}
}


