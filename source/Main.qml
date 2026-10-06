import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item{
    id: root

    //========= VARIABLES =========
    property int seltheme: Number(app.readConfig(2))
    property int favwidth: Number(app.readConfig(3))
    property int favheight: Number(app.readConfig(4))
    property bool remres: {if(app.readConfig(5)==="true") true; else false}
    property int sortmode: app.readConfig(6) || 1
    property int noteamount: app.readConfig(7) || 20;
    property int themeamount: app.readConfig(8) || 12;
    property real notesize: app.readConfig(9) || 120

    property string themename: (app.readTheme(seltheme, 1)) || "No Theme"
    property font selfont: app.readTheme(seltheme, 2) || Qt.application.font.family
    property color textcolor: app.readTheme(seltheme, 3) || "#000000"
    property string bg: vpath(app.readTheme(seltheme, 4))
    property color bgcolor: app.readTheme(seltheme, 5) || "#555555"
    property string notetexture: vpath(app.readTheme(seltheme, 6))
    property color notecolor: app.readTheme(seltheme, 7) || "#ffffff"
    property color notebordercolor: app.readTheme(seltheme, 8) || "#888888"
    property color buttoncolor: app.readTheme(seltheme, 9) || "#DDDDDD"
    property int fillmode: Number(app.readTheme(seltheme, 10))
    property real notetextureopacity: app.readTheme(seltheme, 11) || "1"
    property color shinecolor: app.readTheme(seltheme, 12) || "#FFFFFFFF"

    property int selectednote
    property bool resizemode: false
    //====================================

    component QButton: Button{
        width: 100
        height: 28

        property string stylecolor: buttoncolor

        background: Rectangle{
            width: parent.width
            height: parent.height
            color: "#00000000"
            border.width: 1
            border.color: lighten(buttoncolor)

            Rectangle{width: parent.width; height: 1; color: darken(stylecolor)}
            Rectangle{width: 1; height: parent.height; color: darken(stylecolor)}
            gradient: Gradient{
                GradientStop {position: 0; color: lighten(stylecolor)}
                GradientStop {id: colorgradient; position: 0.5; color: stylecolor}
            }
        }

        Rectangle{width: parent.width; height: parent.height; color: "#000000"; opacity: parent.down? 0.3 : 0}
        Rectangle{width: parent.width; height: parent.height; color: "#FFFFFF"; opacity: parent.hovered&!parent.down? 0.5 : 0}
    }
    component QRectangle: Rectangle{
        Rectangle{width: parent.width; height: parent.height; color: "#000000"; opacity: rectanglemousearea.containsPress? 0.3 : 0; z: 3}
        Rectangle{width: parent.width; height: parent.height; color: "#FFFFFF"; opacity: rectanglemousearea.containsMouse&!rectanglemousearea.containsPress? 0.5 : 0; z: 3}
        MouseArea{
            id: rectanglemousearea
            width: parent.width; height: parent.height;
            hoverEnabled: true
        }
    }
    component QPopup: Popup{
        background: Rectangle{
            color: lighten(bgcolor)
            border.color: darken(bgcolor)
            border.width: 2
        }
    }

    Component.onCompleted: {mainwindow.show()}


//MAIN WINDOW
ApplicationWindow {
    id: mainwindow
    visible: true
    title: "Chromanote"
    palette{
        id: themepalette

        window: bgcolor
        base: lighten(bgcolor)
        text: textcolor
        windowText: textcolor
        button: buttoncolor
        buttonText: textcolor
    }
    font: selfont
    minimumWidth: 200
    minimumHeight: 100

    Component.onCompleted: {
        if(app.readConfig(5)==="true")
        {width = favwidth; height = favheight}
        else
        {width = 582; height = 679}
    }
    onWidthChanged: {if(remres===true) {favwidth = width; app.writeConfig(3, favwidth);}}
    onHeightChanged: {if(remres===true) {favheight = height; app.writeConfig(4, favheight);}}

    background: Loader{
        active: app.checkValidPath(bg)
        sourceComponent: Image {
            source: bg;
            fillMode: fillmode;
            verticalAlignment: Image.AlignTop;
            horizontalAlignment: Image.AlignLeft
            z: -2
        }
    }

    Item {
        id: ctrlcheck
        anchors.fill: parent
        focus: mainwindow.active

        MouseArea{
            width: parent.width
            height: parent.height
            onMouseXChanged: {
                forceActiveFocus(mainwindow)
            }
        }

        Keys.onPressed: (event)=> { //create event on key press
            if (event.key === Qt.Key_Control)
                resizemode = true
        }
        Keys.onReleased: (event)=> {
            if (event.key === Qt.Key_Control)
                resizemode = false
        }
    }
    onFocusObjectChanged: {
        if(!(activeFocusItem instanceof TextField))
        ctrlcheck.forceActiveFocus()
    }

    //MENU
    Item {
        id: menu

        QButton {
            id: options
            anchors.left: parent.left
            height: 26
            text: "Options"
            opacity: editwindow.visible? 0.5 : 1

            onClicked: {
                if(!editwindow.visible)
                {
                    optionswindow.show()
                    optionswindow.requestActivate()
                }
                else
                editwindow.requestActivate() //focus shift
            }
        }

        QButton {
            id: info
            anchors.left: options.right
            x: 100
            height:26
            text: "Info"

            onClicked: {
                infowindow.show();
            }
        }

        TextField{
            id: welcome1
            anchors.right: mainwindow.right
            x: 200;
            y: -10
            width: mainwindow.width - 200
            height: 100
            color: textcolor
            font.pixelSize: 40
            text: app.readConfig(1)
            horizontalAlignment: TextInput.AlignRight;
            rightPadding: 20
            background: Item {}
            visible: mainwindow.width>=400

            Rectangle{
                anchors.fill: parent
                width: parent.width
                height: parent.height
                color: "#FFFFFF"
                opacity: welcome1.activeFocus? 0.2 : 0
                Label{
                    y: 16
                    text: "Press ENTER to confirm."
                    font.pixelSize: 10
                }
            }

            ColorAnimation {
                id: pulse1
                target: welcome1
                property: "color"
                from: Qt.rgba(1-textcolor.r, 1-textcolor.g, 1-textcolor.b, 1)
                to: textcolor
                duration: 500
            }

            onVisibleChanged: {
                if(!visible)
                text = welcome2.text //if editing is cancelled by resizing, fall back to other text to reset.
            }

            onAccepted: {
                app.writeConfig(1, welcome1.text);
                pulse1.start()
                welcome2.text = welcome1.text;
                ctrlcheck.forceActiveFocus()
            }
        }

        TextField{
            id: welcome2
            x: 20;
            y: 16
            height: 100
            color: textcolor
            font.pixelSize: 40
            text: app.readConfig(1)
            background: Item {}
            visible: mainwindow.width<400

            Rectangle{
                anchors.fill: parent
                width: parent.width
                height: parent.height
                color: "#FFFFFF"
                opacity: welcome2.activeFocus? 0.2 : 0
                Label{
                    y: 16
                    text: "Press ENTER to confirm."
                    font.pixelSize: 10
                }
            }

            ColorAnimation {
                id: pulse2
                target: welcome2
                property: "color"
                from: Qt.rgba(1-textcolor.r, 1-textcolor.g, 1-textcolor.b, 1)
                to: textcolor
                duration: 500
            }

            onVisibleChanged: {
                if(!visible)
                text = welcome1.text
            }

            onAccepted: {
                app.writeConfig(1, welcome2.text);
                pulse2.start()
                welcome1.text = welcome2.text;
                ctrlcheck.forceActiveFocus()
            }
        }
    }

    //NOTE SCROLL
    Flickable{
        id: grid
        x: 0; y: 64;
        width: mainwindow.width; height: mainwindow.height;
        clip: true;
        contentWidth: flow.width
        contentHeight: flow.height
        interactive: false

        ScrollBar.vertical: ScrollBar {policy: ScrollBar.AsNeeded}

        Label{
            id: notesizesign
            anchors.horizontalCenter: parent.horizontalCenter
            text: notesize
            color: "#00000000"
            ColorAnimation {
                id: pulsesign
                target: notesizesign
                property: "color"
                from: textcolor
                to: "#00000000"
                duration: 1000
            }
        }

        WheelHandler {
            onWheel: (event) => {
                if(!resizemode)
                {
                    if(grid.contentY - event.angleDelta.y*0.4 >= 0){
                        if(grid.contentY - event.angleDelta.y*0.4 < flow.height)
                            grid.contentY -= event.angleDelta.y*0.4
                    }
                    else
                        grid.contentY = 0
                }
                else
                {
                    if(event.angleDelta.y>0 && notesize < 1000)
                    {
                        notesize +=10
                        app.writeConfig(9, notesize)
                    }
                    else if(event.angleDelta.y<0 && notesize>10)
                    {
                        notesize -=10
                        app.writeConfig(9, notesize)
                    }
                    pulsesign.restart()
                }

            }
        }

        function checkNoteCollision(id1)
        {
            let dragcursorx = provider.itemAt(id1).x + provider.itemAt(id1).draggingx;
            let dragcursory = provider.itemAt(id1).y + provider.itemAt(id1).draggingy;

            for (var j=0; j<noteamount; j++)
            {
                if(id1!==j
                    && dragcursorx >= provider.itemAt(j).x
                    && dragcursorx <= provider.itemAt(j).x + notesize
                    && dragcursory >= provider.itemAt(j).y
                    && dragcursory <= provider.itemAt(j).y + notesize)
                {
                    console.log("swap: "+id1+ " " + j)

                    app.swapNote(id1, j);
                    allnotemodelReload();
                    return true;
                }
            }
        }

        Flow { //note arranger
            id: flow
            x: 40; y: 30;
            width: mainwindow.width-60;
            spacing: Math.min(notesize*0.2, 20)

            property bool isvalidtexture: app.checkValidPath(notetexture)? true : false

            Repeater{ //provider, uses a Component
                id: provider
                model: notemodel
                delegate: Rectangle { //note block
                    id: noteblock
                    width: notesize
                    height: notesize
                    property real draggingx: notemousearea.mouseX //alias breaks
                    property real draggingy: notemousearea.mouseY

                    Rectangle{
                        id: border
                        width: parent.width
                        height: width
                        border.color: notebordercolor
                        border.width: 2
                        color: "#00000000"
                        z: 1
                    }

                    gradient: Gradient{
                        id: shine
                        GradientStop {position: 0; color: if(!notemousearea.containsMouse) shinecolor; else if (notemousearea.pressed) darken(shinecolor); else lighten(shinecolor)}
                        GradientStop {position: 0.5; color: if(!notemousearea.containsMouse) notecolor; else if (notemousearea.pressed) darken(notecolor); else lighten(notecolor)}
                    }

                    Loader{
                        active: flow.isvalidtexture
                        sourceComponent: Image {
                            source: notetexture
                            fillMode: Image.Stretch
                            width: noteblock.width
                            height: width
                            opacity: notetextureopacity
                            z: -1
                        }
                    }

                    Label{
                        x: 4
                        y: 4
                        width: parent.width - 4
                        height: parent.height - 4
                        text: model.title;
                        font: selfont
                        clip: true

                        fontSizeMode: Text.Fit
                        wrapMode: Text.Wrap
                        z: 3
                    }

                    Label{
                        x: 0
                        y: 0
                        width: parent.width - 4
                        height: parent.width - 4
                        padding: 1
                        text: "+"
                        color: textcolor
                        font: selfont
                        clip: true
                        opacity: model.exists? 0 : 1
                        horizontalAlignment: "AlignRight"

                        z: 3
                    }

                    property int nproperx: parent.x;
                    property int npropery: parent.y;
                    DragHandler{
                        id: notedrag
                        enabled: !sortmode
                        onActiveChanged: {
                            if(active)
                            {
                                notemousearea.hoverEnabled= false; //let other elements have focus
                                nproperx = parent.x;
                                npropery = parent.y;
                            }
                            else
                            {
                                notemousearea.hoverEnabled= true;
                                if(grid.checkNoteCollision(model.n))
                                {
                                    parent.x = parent.nproperx
                                    parent.y = parent.npropery
                                }

                                else
                                {
                                    parent.x = parent.nproperx
                                    parent.y = parent.npropery
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: notemousearea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            selectednote = model.n

                            var noteinstance = notewindowcomponent.createObject(mainwindow, {currentnote: selectednote});
                            noteinstance.show()
                        }
                    }
                    Rectangle{width: parent.width; height: parent.height; color: "#000000"; opacity: notemousearea.containsPress||notedrag.active? 0.2 : 0; z: 3}
                    Rectangle{width: parent.width; height: parent.height; color: "#FFFFFF"; opacity: notemousearea.containsMouse&!(notemousearea.containsPress||notedrag.active)? 0.2 : 0; z: 3}
                }
            }
        }
    }

    //NOTE WINDOW
    Component{
        id: notewindowcomponent

        ApplicationWindow {
                id: notewindow
                title: "Note"
                width: 600
                x: mainwindow.x + mainwindow.width
                y: mainwindow.y
                height: 400
                transientParent: mainwindow
                flags: Qt.Tool
                color: mainwindow.color
                palette: themepalette
                font: selfont

                property int currentnote: mainwindow.selectednote

                onVisibleChanged: { //runs when the window opens/closes
                    if (visible)
                        title.text = app.readTitle(currentnote)
                        input.text = app.readNote(currentnote)
                }

                TextField {
                    id: title
                    anchors.top: parent.top
                    width: parent.width
                    height: 30
                    font.family: selfont

                    background: Rectangle{
                        color: notecolor
                        border.color: notebordercolor
                    }
                    text: app.readTitle(notewindow.currentnote)
                }
                TextArea {
                    id: input
                    y: 30
                    width: parent.width*0.9
                    height: parent.width*0.9
                    font.family: selfont

                    text: app.readNote(notewindow.currentnote)
                    background: Rectangle{
                        color: notecolor
                        border.color: notebordercolor

                        gradient: Gradient{
                            GradientStop {position: -0.25; color: shinecolor}
                            GradientStop {position: 0.5; color: notecolor}
                        }
                    }

                }
                QButton {
                    anchors.bottom: parent.bottom
                    text: "Save"

                    onClicked: {
                        if(title.text===""&&input.text==="")
                        {
                            if(app.checkValidPath("file:///" + exeDir + "/notes/note"+currentnote+".txt"))
                                app.deleteNote(currentnote)
                        }
                        else
                        {
                            app.writeTitle(title.text, notewindow.currentnote)
                            app.writeNote(input.text, notewindow.currentnote)
                            app.writeQ(notewindow.currentnote)
                        }
                        notemodelReload(currentnote)
                    }
                }
                QButton {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    text: "🗑"
                    width: 32
                    height: width

                    onClicked: {
                        deletenotepopup.open()
                    }
                }
                QPopup{
                    id: deletenotepopup
                    anchors.centerIn: parent
                    width: 400
                    height: 128

                    Label{
                        id: deletenotetext
                        padding: 5
                        text: "Are you sure you want to delete this note?"
                        wrapMode: "WordWrap"
                    }
                    QButton{
                        id: deletenoteno
                        anchors.top: deletenotetext.bottom
                        anchors.topMargin: 32
                        x: 64

                        text: "No"
                        onClicked: {
                            deletenotepopup.close()
                        }
                    }
                    QButton{
                        id: deletenoteyes
                        anchors.top: deletenotetext.bottom
                        anchors.left: deletenoteno.right
                        anchors.leftMargin: 64
                        anchors.topMargin: 32
                        text: "Yes"

                        onClicked: {
                            app.deleteNote(currentnote)
                            deletenotepopup.close()
                            notewindow.close()
                            notemodelReload(currentnote)
                        }
                    }
                }
            }
    }

    //INFO WINDOW
    ApplicationWindow {
        id: infowindow
        title: "Info"
        palette: themepalette
        width: 760
        height: 346
        font: selfont

        Image{
            x: 20
            y: 20
            source: vpath("/icon.png")
            width: parent.width*0.4
            height: width
        }

        Rectangle{
            x: parent.width/2
            y: 20
            width: parent.width/2 -20
            height: parent.height -40
            color: lighten(bgcolor)
            border.width: 1
            border.color: darken(bgcolor)

            Label{
                id: infotext
                padding: 8
                width: parent.width
                height: implicitHeight
                wrapMode: "WordWrap"

                text: "Chromanote is a free, simple and customisable notes program developed by Davide Sollo.
\n\nCopyright © 2026 [Daviyume].\nLicensed under GPLv3.\n"
            }
            Label{
                id: thx
                anchors.top: infotext.bottom
                padding: 8
                width: parent.width
                height: implicitHeight
                horizontalAlignment: Text.AlignHCenter
                wrapMode: "WordWrap"

                text: "Thank you for downloading!\n"
            }
            Text{
                id: ghlink
                anchors.top: thx.bottom
                width: parent.width/2
                horizontalAlignment: Text.AlignHCenter

                text: "<a href='https://github.com/daviyume'>GitHub</a>"
                onLinkActivated: (link) => Qt.openUrlExternally(link)
            }
            Text{
                id: qt
                anchors.top: thx.bottom
                anchors.left: ghlink.right
                width: parent.width/2
                horizontalAlignment: Text.AlignHCenter

                text: "Made with <a href='https://qt.io'>Qt</a>"
                onLinkActivated: (link) => Qt.openUrlExternally(link)
            }

            Label{
                id: ver
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                padding: 2
                text: "1.0"
            }
            }

    }

    // OPTIONS WINDOW
    ApplicationWindow {
        id: optionswindow
        title: "Options"
        width: 800
        height: 600
        color: bgcolor
        palette: themepalette
        font: selfont

        Label {
            id: noteamountlabel
            x: 10
            y: 10

            text: "Number of notes: "
            TextField {
                anchors.left: noteamountlabel.right
                y: -2
                width: 40
                id: noteamountinput
                text: noteamount
                onTextChanged: {
                    if(focus)
                    {
                        noteamountslider.value = noteamountinput.text
                        app.writeConfig(7, noteamountinput.text)
                        noteamount = Number(noteamountinput.text)
                        allnotemodelReload()
                    }
                }
            }
        }

        Slider {
            id: noteamountslider
            x: 10
            y: 50
            width: optionswindow.width*0.5

            from: 10
            value: noteamount
            to: 100
            stepSize: 10
            snapMode: Slider.SnapAlways

            onValueChanged: {
                if(pressed)
                {
                    noteamountinput.text = noteamountslider.value
                    app.writeConfig(7, noteamountslider.value)
                    noteamount = noteamountslider.value
                    allnotemodelReload()
                }
            }
        }

        Label {
            x: 10
            y: 80

            text: "Theme"
        }
        QButton{
            id: themebutton
            x: 10
            y: 110
            width: 300

            text: app.checkValidTheme(seltheme)? app.readTheme(seltheme, 1) : "(no theme)"

            onClicked: {
                themeselect.open()
            }
        }

        QPopup{ // THEME SELECT
            id: themeselect
            x: themebutton.x
            y: themebutton.y
            width: 700
            height: 400
            padding: 20
            clip: true

            Label{
                anchors.horizontalCenter: themespinbox.horizontalCenter
                anchors.bottom: themespinbox.top
                bottomPadding: 4
                text: "Amount:"
            }

            SpinBox{
                id: themespinbox
                y: 30
                anchors.right: themegrid.right
                width: 60
                height: 40
                value: themeamount
                z: 2

                onValueModified:{
                    if(value<themeamount)
                    thememodel.remove(value)

                    app.writeConfig(8, value)
                    themeamount = value;
                    thememodelReload(value-1)
                }

            }

            GridView{ // THEME GRIDVIEW
                id: themegrid
                width: parent.width
                height: parent.height
                cellWidth: 196
                cellHeight: 128
                model: thememodel

                function checkThemeCollision(id1)
                {
                    let tdragcursorx = themegrid.itemAtIndex(id1).x + themegrid.itemAtIndex(id1).tdraggingx;
                    let tdragcursory = themegrid.itemAtIndex(id1).y + themegrid.itemAtIndex(id1).tdraggingy;

                    for (var j=0; j<themeamount; j++)
                    {
                        if(id1!==j
                            && tdragcursorx >= themegrid.itemAtIndex(j).x
                            && tdragcursorx <= themegrid.itemAtIndex(j).x + themegrid.itemAtIndex(j).width
                            && tdragcursory >= themegrid.itemAtIndex(j).y
                            && tdragcursory <= themegrid.itemAtIndex(j).y + themegrid.itemAtIndex(j).height)
                        {
                            console.log(id1+ " " + j)

                            app.swapTheme(id1, j);
                            thememodelReload(id1);
                            thememodelReload(j);
                            return true;
                        }
                    }
                }

                delegate: Rectangle {
                    id: themedelegate
                    width: GridView.view.cellWidth -10
                    height: GridView.view.cellHeight -10
                    border.color: model.id===seltheme&&model.id!==""? "#FFFFFF" : darken(model.bgcolor)
                    border.width: model.id===seltheme? 4 : 2
                    color: model.bgcolor
                    clip: true

                    property real tdraggingx: thememousearea.mouseX //alias would break
                    property real tdraggingy: thememousearea.mouseY

                    property int tproperx: (themeamount<=model.id)? parent.x : 0; //to remember original pos after drag
                    property int tpropery: (themeamount<=model.id)? parent.y : 0;

                    DragHandler{
                        enabled: true
                        onActiveChanged: {
                            if(active)
                            {
                                thememousearea.hoverEnabled= false; //let other elements have focus
                                tproperx = parent.x;
                                tpropery = parent.y;
                            }
                            else
                            {
                                thememousearea.hoverEnabled= true;
                                if(themegrid.checkThemeCollision(model.id))
                                {
                                    parent.x = parent.tproperx
                                    parent.y = parent.tpropery
                                }

                                else
                                {
                                    parent.x = parent.tproperx
                                    parent.y = parent.tpropery
                                }
                            }
                        }
                    }

                    /* BG PREVIEW
                    Loader{
                        width: themedelegate.width
                        height: themedelegate.height
                        active: app.checkValidPath(model.bg)
                        sourceComponent: Image {
                            source: model.bg || ""
                            fillMode: Number(model.fillmode); verticalAlignment: Image.AlignTop; horizontalAlignment: Image.AlignLeft
                        }
                    }
                    */

                    QButton{
                        width: parent.width
                        height: 24
                        text: model.title
                        font: model.textfont || Qt.application.font.family
                        palette.buttonText: model.textcolor

                        stylecolor: if(!thememousearea.containsMouse) model.buttoncolor; else if (thememousearea.pressed) darken(model.buttoncolor); else lighten(model.buttoncolor)
                    }

                    Loader{
                        active: app.checkValidPath(model.notetexture)
                        sourceComponent: Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 20
                            width: 0
                            height: 0
                            source: model.notetexture
                        }
                    }

                    Rectangle{
                        x: 32
                        y: 32
                        width: 64
                        height: width
                        color: model.notecolor
                        border.color: model.notebordercolor
                        border.width: 2

                        Label{
                            x: 3
                            y: 4
                            text: "..."
                            color: model.textcolor
                            font.family: model.textfont
                        }
                    }

                    MouseArea {
                        id: thememousearea
                        hoverEnabled: true

                        anchors.fill: parent
                        onClicked: {
                            if(app.checkValidTheme(model.id))
                            {
                                app.writeConfig(2, model.id)
                                seltheme = model.id
                            }
                            else
                            {
                                app.createTheme(model.id)
                                app.writeConfig(2, model.id)
                                seltheme = model.id
                                thememodelReload(seltheme)
                                editwindow.show()
                                optionswindow.close()
                            }
                            themeselect.close();
                        }
                    }
                }
            }
        }

        QButton{
            id: edittheme
            anchors.left: themebutton.right
            anchors.leftMargin: 16
            y: 110
            width: 80

            text: "Edit"

            property int themetorefresh;
            onClicked: {
                if(!app.checkValidTheme(seltheme))
                {
                    themetorefresh= seltheme
                    app.createTheme(seltheme)
                    thememodelReload(seltheme)
                    seltheme= -1
                    seltheme= themetorefresh
                }
                editwindow.show()
                optionswindow.close()
            }
        }

        QButton{
            id: deletetheme
            anchors.left: edittheme.right
            anchors.leftMargin: 16
            y: 110
            width: 80

            text: "Delete"


            onClicked: {
                deletethemepopup.open()
            }

            ToolTip{
                id: deletethemetip
                visible: parent.hovered
                delay: 500
                text: "delete current theme in use"
                font.pixelSize: 10
                font.italic: true
            }
        }

        Popup{
            id: deletethemepopup
            x: deletetheme.x+deletetheme.width+16
            y: deletetheme.y-deletetheme.height
            width: 128
            height: 64

            Label{
                text: "Are you sure?"
            }

            Button{
                y: deletetheme.height-deletethemepopup.padding
                width: 64
                text: "Yes"
                property int themetorefresh;
                onClicked: {
                    themetorefresh= seltheme
                    app.deleteTheme(seltheme)
                    seltheme= -1
                    seltheme= themetorefresh
                    thememodelReload(seltheme)
                    deletethemepopup.close()
                }
            }
        }

        //SORT
        Label{
            x: 10
            y:165
            text: "Sort:"
        }

        ButtonGroup{id: sortselection}
        RadioButton{
            x: 80
            y: 160
            ButtonGroup.group: sortselection
            text: "by recent"
            checked: sortmode===1

            onCheckedChanged: {
                if(checked)
                    sortmode=1;
                else
                    sortmode=0;
                app.writeConfig(6, sortmode)
                allnotemodelReload();
            }
        }

        RadioButton{
            x: 200
            y: 160
            ButtonGroup.group: sortselection
            text: "custom"
            checked: sortmode===0
        }

        CheckBox {
            id: resolutioncheck
            x: 10
            y: 200
            text: "Remember window resolution"
            checked: remres

            onClicked: {
                remres = checked
                app.writeConfig(5, remres)
                if(checked===true)
                {
                    favwidth = mainwindow.width; app.writeConfig(3, favwidth)
                    favheight = mainwindow.height; app.writeConfig(4, favheight)
                }
            }
        }


    }

}

//EDIT WINDOW
ApplicationWindow {
    id: editwindow
    title: themename
    width: 800
    height: 680
    minimumWidth: 640
    minimumHeight: 450
    font.family: Qt.application.font.family
    palette{id: editwindowpalette}

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
        pfillmode = fillmode!==""? fillmode : Image.PreserveAspectCrop
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

        property string pbg: vpath(editbg.text)
        property string pnotetexture: vpath(editnotetexture.text)

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
            active: app.checkValidPath(preview.pbg)
            sourceComponent: Image {
                width: editwindow.width*0.66
                height: editwindow.height*0.5
                source: preview.pbg;

                fillMode: editwindow.pfillmode
                verticalAlignment: Image.AlignTop;
                horizontalAlignment: Image.AlignLeft
            }
        }

        //box
        Rectangle {
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
                GradientStop {position: 0; color: editshinecolor.text}
                GradientStop {position: 0.5; color: editnotecolor.text}
            }

            Loader{
                active: app.checkValidPath(preview.pnotetexture)
                sourceComponent: Image {
                    source: preview.pnotetexture || ""
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

        //button
        QButton{
            x: preview.width*0.6
            y: preview.height*0.2
            width: 100
            height: 26
            text: "Button"
            palette.buttonText: edittextcolor.text
            stylecolor: editbuttoncolor.text

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

                Component.onCompleted: {editfont.currentIndex = editfont.find(selfont.family)}

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

                    onClicked: {fontdial.open()}
                }
            }

            FontDialog{
                options: FontDialog.DontUseNativeDialog
                id: fontdial
                selectedFont: editwindow.pselfont

                onAccepted: {editwindow.pselfont = selectedFont}
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
                    var cleanpath = selectedFile.toString().replace("file:///", "")
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
                    var cleanpath = selectedFile.toString().replace("file:///", "")
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
        stylecolor: editbuttoncolor.text
        palette.buttonText: edittextcolor.text

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
            themetorefresh = seltheme;
            seltheme = -1; //update all variables binded to seltheme
            seltheme = themetorefresh;
            thememodelReload(seltheme); //reload at the end to not confuse repeaters when seltheme is -1
        }
    }

    Rectangle{width:4; height: editwindow.height; color: "#444444"; anchors.right: parent.right}
    Rectangle{width:editwindow.width; height: 4; color: "#444444"; anchors.bottom: parent.bottom}
}


//MODELS
ListModel {
    id: notemodel

    Component.onCompleted: {
        allnotemodelReload();
    }
}
ListModel {
    id: thememodel
    Component.onCompleted: {
        for (var i = 0; i<themeamount; i++) {
            thememodel.append({
                id: i,
                title: app.readTheme(i, 1),
                textfont: app.readTheme(i, 2),
                textcolor: app.readTheme(i, 3),
                bg: app.readTheme(i, 4),
                bgcolor: app.readTheme(i, 5),
                notetexture: app.readTheme(i, 6),
                notecolor: app.readTheme(i, 7),
                notebordercolor: app.readTheme(i, 8),
                buttoncolor: app.readTheme(i, 9),
                fillmode: app.readTheme(i, 10),
                textureopacity: app.readTheme(i, 11),
                shinecolor: app.readTheme(i, 12),

                elementy: app.readTheme(i, 13),
                elementwidth: app.readTheme(i, 14),
                Z: app.readTheme(i, 15)
            })
        }
    }
}

//FUNCTIONS
function notemodelReload(i)
{
    notemodel.set(i, {
    n: app.readOrder(i),
    title:app.readTitle(app.readOrder(i)),
    exists: app.checkValidLocalPath("notes/note"+i+".txt")
    })
}

function allnotemodelReload()
{
    notemodel.clear();
    app.chooseOrder(sortmode)
    for (var i = 0; i<noteamount; i++)
    notemodel.append({n: app.readOrder(i), title:app.readTitle(app.readOrder(i)), exists: app.checkValidPath("file:///" + exeDir + "/notes/note"+i+".txt")})
}

function thememodelReload(i)
{
    thememodel.set(i, {
    id: i,
    title: app.readTheme(i, 1),
    textfont: app.readTheme(i, 2),
    textcolor: app.readTheme(i, 3),
    bg: app.readTheme(i, 4),
    bgcolor: app.readTheme(i, 5),
    notetexture: app.readTheme(i, 6),
    notecolor: app.readTheme(i, 7),
    notebordercolor: app.readTheme(i, 8),
    buttoncolor: app.readTheme(i, 9),
    fillmode: app.readTheme(i, 10),
    textureopacity: app.readTheme(i, 11),
    shinecolor: app.readTheme(i, 12),
    })
}

function allthememodelReload()
{
    for(var i=0; i<themeamount; i++)
        thememodelReload(i)
}

function darken(col)
{
    if(col==="")
        return "#000000"
    col = Qt.color(col) //palette colors break when passed into Qt.rgba
    return Qt.rgba(col.r*0.66, col.g*0.66, col.b*0.66, col.a)
}

function lighten(col)
{
    if(col==="")
        return "#FFFFFF"
    col = Qt.color(col)
    if(col.r + col.g + col.b < 0.75)
        return Qt.rgba(0.1+col.r*3, 0.1+col.g*3, 0.1+col.b*3, col.a)
    else
        return Qt.rgba(col.r*1.25, col.g*1.25, col.b*1.25, col.a)
}

function vpath(path)
{
    //check for both local and absolute path. If path is local, attach full path so QML can find it. Use '/' before argument
    if(app.isPathLocal(path))
        return "file://" + exeDir + path;
    else
        return path;
}

}