#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <fstream>
#include <QQmlContext>
#include <QFont>
#include <QFontDatabase>
#include <string>
#include <QDebug>
#include <filesystem>
#include <QString>
#include <QStandardPaths>
#include <ctime>
#include <stdio.h>
#include <system_error>
#include <QIcon>
#include <QCoreApplication>
#include <QDir>
#include <QFile>

namespace fs = std::filesystem;
using std::fstream;
using std::ifstream;
using std::ofstream;
using std::ios;
using std::string;
//fs::path dir = fs::path((QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).toStdString()) / "Chromanote"; //Set Execution Directory
fs::path dir = "";
int order[100];

void write(QString msg, fs::path path, int pos)
{
    string pre; //stores characters before mid
    string mid; //stores inserted characters
    string post; //stores characters after mid
    string temp; //line accumulutaor for pre

    fstream file(path, ios::in | ios::out);
    file.seekg(std::ios::beg);

    for(int i=1; i<pos; i++)
    {
        getline(file, temp, '\x1E');
        pre+= temp + "\x1E";
    }
    file.ignore(std::numeric_limits<std::streamsize>::max(), '\x1E');

    mid = msg.toStdString() + "\n\x1E";

    getline(file, post, '\x1F');
    post += "\x1F\x1F";

    string newfile = pre + mid + post;

    file.close();
    file.open(path, ios::out | ios::trunc);

    //fs::resize_file(path, 0); //purge to prevent confusion on write
    file.clear(); //use it after end of file
    file.seekp(0, ios::beg);
    file<<newfile;

    file.close();
}

QString read(fs::path path, int pos)
{
    if(!fs::exists(path))
    {
        return "";
    }

    ifstream file(path, ios::out);
    file.seekg(ios::beg);

    string msg;
    for(int i=pos; i>1; i--)
        file.ignore(std::numeric_limits<std::streamsize>::max(), '\x1E');
    getline(file, msg, '\x1E');
    file.close();

    if(!msg.empty())
    msg.pop_back(); //remove endl
    if(!fs::exists(path))
        qDebug()<<"Error: "<<QString::fromStdString(path.string())<<" does not exist.";

    return QString::fromStdString(msg);
}


class app: public QObject
{
    Q_OBJECT
public:

    //  NOTES
    Q_INVOKABLE QString readTitle(int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        return read(path, 1);
    }
    Q_INVOKABLE void writeTitle(QString words, int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        write(words, path, 1);
    }

    Q_INVOKABLE QString readNote(int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        return read(path, 2);
    }
    Q_INVOKABLE void writeNote(QString words, int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        write(words, path, 2);
    }

    Q_INVOKABLE void deleteNote(int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        QFile::moveToTrash(path);
    }

    //  Q = time variable of note
    QString readQ(int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        return read(path, 3);
    }
    Q_INVOKABLE void writeQ(int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        write(QString::number(std::time(nullptr)), path, 3);
    }

    //  Z = order variable of note
    Q_INVOKABLE void writeZ(QString words, int id)
    {
        fs::path path = dir / ("notes/note"+std::to_string(id)+".txt");
        write(words, path, 4);
    }

    //  config.txt
    Q_INVOKABLE QString readConfig(int pos)
    {
        fs::path path = dir / ("config.txt");
        if(!fs::exists(path))
        {
            resetConfig();
        }
        return read(path, pos);
    }
    Q_INVOKABLE void writeConfig(int pos, QString config)
    {
        fs::path path = dir / "config.txt";
        write(config, path, pos);
    }
    void resetConfig()
    {
        fs::path path = dir / "config.txt";
        fstream file(path, ios::out | ios::trunc);
        file<<"Welcome\n"//welcome
                "\x1E" "0" "\n"//seltheme
                "\x1E" "582" "\n"//remwidth
                "\x1E" "679" "\n"//remheight
                "\x1E" "true" "\n"//remembersize
                "\x1E" "0" "\n"//sortmode
                "\x1E" "20" "\n"//noteamount
                "\x1E" "12" "\n"//themeamount
                "\x1E" "120" "\n"//notesize
                "\x1E" "\x1F";//end
    }

    //  THEMES
    Q_INVOKABLE QString readTheme(int id, int pos)
    {
        fs::path path = dir / ("themes/theme" + std::to_string(id) + ".txt");
        return read(path, pos);
    }
    Q_INVOKABLE void writeTheme(int id, int pos, QString config)
    {
        fs:: path path = dir / ("themes/theme"+std::to_string(id)+".txt");
        write(config, path, pos);
    }
    Q_INVOKABLE bool checkValidTheme(int id)
    {
        fs::path path = dir / ("themes/theme" + std::to_string(id) + ".txt");
        if(fs::exists(path))
            return true;
        else
            return false;
    }
    Q_INVOKABLE void createTheme(int id)
    {
        fs::path path = dir / ("themes/theme"+std::to_string(id)+".txt");
        fstream file(path, ios::out | ios::trunc);
        file<<"New Theme\n\x1E"
                "\n\x1E" //font
                "#000000\n\x1E" //textcolor
                "\n\x1E" //bg
                "#bbbbbb\n\x1E" //bgcolor
                "\n\x1E" //notetexture
                "#FFFFFF\n\x1E" //notecolor
                "#888888\n\x1E" //notebordercolor
                "#DDDDDD\n\x1E" //button color
                "2\n\x1E" //fillmode
                "\n\x1E" //textureopacity
                "\n\x1E" //shinecolor
                "\x1F" //end
            ;
    }
    Q_INVOKABLE void deleteTheme(int id)
    {
        fs::path path = dir / ("themes/theme"+std::to_string(id)+".txt");
        fs::remove(path);
    }

    // UTILITIES
    Q_INVOKABLE QStringList loadFonts()
    {
        return QFontDatabase::families();
    }


    string convertQmlPath(QString qmlpath)
    {
        //qml works on full file:/// paths only, while c++ on /home paths and local paths.
        //this function converts full paths from Qml into local paths for C++ to use, like for checkValidPath().
        QUrl url(qmlpath);
        fs::path cpath = url.toLocalFile().toStdString();
        return cpath.string();
    }

    Q_INVOKABLE bool checkValidPath(QString qmlpath)
    {
        //for qml paths
        fs::path path = convertQmlPath(qmlpath);

        if(fs::exists(path))
            return true;
        else
            return false;
    }

    Q_INVOKABLE bool checkValidLocalPath(QString qmlpath)
    {
        //used for checking existence of local paths like notes or themes
        //when using this function, don't put / at beginning of path (unlike vpath())
        fs::path path = (qmlpath.toStdString());

        if(fs::exists(path))
            return true;
        else
            return false;
    }

    Q_INVOKABLE bool isPathLocal(QString mysterypath)
    {
        if(mysterypath=="")
            return false;

        fs::path path = convertQmlPath(mysterypath);
        if(path.is_relative())
            return true;
        else
            return false;
    }


    Q_INVOKABLE void swapNote(int id1, int id2)
    {
        fs::path path1 = dir / ("notes/note" + std::to_string(id1) + ".txt");
        fs::path path2 = dir / ("notes/note" + std::to_string(id2) + ".txt");

        if(fs::exists(path2))
        fs::rename(path2, "notes/temp.txt");
        if(fs::exists(path1))
        fs::rename(path1, "notes/note" + std::to_string(id2) + ".txt");
        if(fs::exists("notes/temp.txt"))
        fs::rename("notes/temp.txt", "notes/note"+ std::to_string(id1) + ".txt");


        qDebug()<<"swap ordered: "<<QString::fromStdString(path2.string())<<" turned into "<<"note"+ std::to_string(id1)+".txt";
    }
    Q_INVOKABLE void swapTheme(int id1, int id2)
    {
        fs::path path1 = dir / ("themes/theme" + std::to_string(id1) + ".txt");
        fs::path path2 = dir / ("themes/theme" + std::to_string(id2) + ".txt");

        if(fs::exists(path2))
            fs::rename(path2, "themes/temp.txt");
        if(fs::exists(path1))
            fs::rename(path1, "themes/theme" + std::to_string(id2) + ".txt");
        if(fs::exists("themes/temp.txt"))
            fs::rename("themes/temp.txt", "themes/theme"+ std::to_string(id1) + ".txt");


        qDebug()<<"swap ordered: "<<QString::fromStdString(path2.string())<<" turned into "<<"theme"+ std::to_string(id1)+".txt";
    }

    Q_INVOKABLE void chooseOrder(int mode)
    {
        int noteamount = readConfig(7).toInt();
        int q[noteamount]; //q is value 3 of note file, indicating last access

        switch(mode)
        {
            case 0: //manual. reads note file name
            for(int i=0; i<noteamount; i++)
                {
                    order[i] = i;
                }
            break;

            case 1: case 2: //time. reads q (value 3 in note)
                for(int i=0; i<noteamount; i++)
                {
                    q[i] = (readQ(i)).toInt();
                }

                int prevmax=0;
                int max = 0;
                int cnt = 0;

                //cell 0
                for(int j=0; j<noteamount; j++)
                {
                    if(q[j]>q[prevmax])
                        prevmax = j;
                }

                order[0] = prevmax;

                //cell 1-18
                for(int i=1; i<noteamount-1; i++) //select 19 times
                {
                    for(int j=0; j<noteamount; j++)
                    {
                        if(q[j]>q[max]&&q[j]<q[prevmax])
                            max = j;
                    }


                    order[i] = max;

                    prevmax= max;
                    max= noteamount-1;
                }
                //cell 19
                order[noteamount-1]=noteamount-1;

                break;
        }
    }
    Q_INVOKABLE int readOrder(int id)
    {
        return order[id];
    }

    void nSwap(int &a, int &b)
    {
        int c=a; a=b; b=c;
    }

};


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    class app a;
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/Chromanote/Main.qml"));
    engine.rootContext()->setContextProperty("exeDir", QDir::currentPath());

    app.setWindowIcon(QIcon("icon.png"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("app", &a);
    engine.load(url);

    //QFont defaultFont("Helvetica", 12);

    return app.exec();
}

#include "main.moc"
