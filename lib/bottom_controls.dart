import 'dart:math';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/songs.dart';
import 'package:musicplayer/theme.dart';

class bottomcontrols extends StatelessWidget {


  const bottomcontrols({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return new Container(
      width: double.infinity,

      child: new Material(
        shadowColor: const Color(0x44000000),
        color: accentColor,
        child: new Padding(
          padding: const EdgeInsets.only(top: 40.0,bottom: 50.0),
          child: new Column(
            children: <Widget>[
              new AudioPlaylistComponent(
                playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
                  final songTitle = demoPlaylist.songs[playlist.activeIndex].songTitle;
                  final artistName = demoPlaylist.songs[playlist.activeIndex].artist;

                  return new RichText(
                    text: new TextSpan(
                        text: '',
                        children: [
                          new TextSpan(
                            text: '${songTitle.toUpperCase()}\n',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0,
                              height: 1.5,
                            ),
                          ),
                          new TextSpan(
                            text: '${artistName.toUpperCase()}',
                            style: new TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12.0,
                              letterSpacing: 3.0,
                              height: 1.5,
                            ),
                          ),
                        ]
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),


              new Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(child: new Container()),
                    new previous_button(),
                    new Expanded(child: new Container()),

                    new playPause_button(),

                    new Expanded(child: new Container()),

                    new next_button(),
                    new Expanded(child: new Container()),

                  ],
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}

class playPause_button extends StatelessWidget {
  const playPause_button({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioPlayerState,

      ],
      playerBuilder: (BuildContext context, AudioPlayer player,Widget child){
        IconData icon=Icons.music_note;
        Color buttonColor=lightAccentColor;
        Function onPressed;
        if(player.state==AudioPlayerState.playing){
          icon = Icons.pause;
          buttonColor=Colors.white;
          onPressed=player.pause;
        }
        else if(player.state==AudioPlayerState.paused || player.state==AudioPlayerState.completed){
          icon=Icons.play_arrow;
          onPressed=player.play;
          buttonColor=Colors.white;
        }
        return new RawMaterialButton(shape: new CircleBorder(),fillColor: Colors.white,splashColor: lightAccentColor,highlightColor: lightAccentColor.withOpacity(.50),elevation: 10.0,highlightElevation:5.0 ,onPressed: onPressed, child: new Padding(padding:
        const EdgeInsets.all(8.0),
          child: new Icon(
           icon,color: darkAccentColor,
            size: 35.0,
          ),
        ),
        );
      },

    );
  }
}

class previous_button extends StatelessWidget {
  const previous_button({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  new AudioPlaylistComponent(
      playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
        return new IconButton(
          splashColor: lightAccentColor,
          highlightColor: Colors.transparent,
          icon: new Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 35.0,
          ),
          onPressed: playlist.previous,
        );
      },
    );
  }
}

class next_button extends StatelessWidget {
  const next_button({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  new AudioPlaylistComponent(
      playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
        return new IconButton(
          splashColor: lightAccentColor,
          highlightColor: Colors.transparent,
          icon: new Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 35.0,
          ),
          onPressed: playlist.next,
        );
      },
    );
  }
}

class CircleClipper extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center:  new Offset(size.width/2, size.height/2),
      radius: min(size.width,size.height)/2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
