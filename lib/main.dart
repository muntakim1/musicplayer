import 'dart:math';

import 'package:flutter/material.dart';
import 'package:musicplayer/bottom_controls.dart';
import 'package:musicplayer/songs.dart';
import 'package:musicplayer/theme.dart';
import 'package:fluttery/gestures.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
void main()=>runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
     debugShowCheckedModeBanner: false,
      title: 'Music Player',
      home: new MusicPlayer(),
    );
  }
}

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {

  void _popupmenu(){

  }



  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      home: new AudioPlaylist(
      playlist: demoPlaylist.songs.map((DemoSong song) {
        return song.audioUrl;
      }).toList(growable: false),
        playbackState: PlaybackState.paused,
        child: new Scaffold(
          appBar: new AppBar(
            leading: IconButton(icon: new Icon(Icons.arrow_back_ios),color: Colors.grey, onPressed: (){},),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: new Text("Music Player",style: new TextStyle(color: Colors.grey),),
            actions: <Widget>[
              IconButton(icon:new Icon(Icons.menu,),color:Colors.grey,onPressed: (){_popupmenu();},),
            ],
          ),

          body: new Column(
            children: <Widget>[

              new Expanded(
                  child: new AudioComponent(updateMe:[
                    WatchableAudioProperties.audioSeeking,
                    WatchableAudioProperties.audioPlayhead,
                  ],

                      playerBuilder: (BuildContext context,AudioPlayer player,Widget child){
                 double playbackprograss=0.0;
                 if(player.audioLength!=null && player.position!=null){
                   playbackprograss=player.position.inMilliseconds/player.audioLength.inMilliseconds;
                 }

                  return new RadialSeekBar(
                    seekPercent: playbackprograss,
                  ) ;
        }
                  ),
              ),


              new Container(
                width: double.infinity,
                height: 125.0,
                child: new Visualizer(
                  builder: (BuildContext context,List<int>fft){
                      return new CustomPaint(
                        painter: new VisualizerPainter(
                          fft:fft,
                          height: 100.0,
                          color: accentColor,
                        ),
                        child: new Container(),
                      )    ;
                  },
                ),

              ),

              new bottomcontrols(),





            ],
          ),

        ),
      ),
    );
  }
}

class VisualizerPainter extends CustomPainter{

  final List<int>fft;
  final double height;
  final Color color;
  final Paint wavepaint;

  VisualizerPainter({
    this.fft,
    this.height,
    this.color,
}): wavepaint=new Paint()
..color=color.withOpacity(0.75)
  ..style=PaintingStyle.fill;



  @override
  void paint(Canvas canvas, Size size) {

        _renderWaves(canvas,size);
  }

void _renderWaves(Canvas canvas, Size size){
    final histogramLow=createHistorgram(fft,15,2,((fft.length)/4).floor());
    final histogramHigh=createHistorgram(fft,15,(fft.length/4).ceil(),(fft.length/2).floor());
    _renderHistogram(canvas,size,histogramLow);
    _renderHistogram(canvas,size,histogramHigh);
  }

void _renderHistogram(Canvas canvas,Size size,List<int>histogram){
    if(histogram.length==0){
      return ;
    }
    final pointToGraph=histogram.length;
    final widthPerSample=(size.width/(pointToGraph-2)).floor();
    final points=new List<double>.filled(pointToGraph*4, 0.0);
    for(int i=0;i<histogram.length-1;++i){
      points[i*4]=(i*widthPerSample).toDouble();
      points[i*4+1]=size.height-histogram[i].toDouble();

      points[i*4+2]=((i+1)*widthPerSample).toDouble();
      points[i*4+3]=size.height-(histogram[i+1].toDouble());
    }

    Path path=new Path();
    path.moveTo(0.0, size.height);
    path.lineTo(points[0], points[1]);
    for(int i=2;i<points.length-4;i+=2){
      path.cubicTo(
      points[i-2]+10.0,
          points[i-1],
          points[i]-10.0,
          points[i-1],points[i],points[i+1]
      );

    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, wavepaint);
}


  List<int>createHistorgram(List<int> samples,int bucketCount,[int start,int end]){
    if(start==end){
      return const [];
  }


  start= start ??0;
    end=end?? samples.length-1;
    final sampleCount= end-start+1;
  final samplesPerBucket=(sampleCount/bucketCount).floor();
  if(samplesPerBucket==0){
    return const [];
  }

  final actualSampleCount = sampleCount-(sampleCount%samplesPerBucket);
  List<int> histogram= new List<int>.filled(bucketCount, 0);


  for(int i=start;i<start+actualSampleCount;++i){
    if((i-start)%2==1){
      continue;
    }

    int bucketIndex=((i-start)/samplesPerBucket).floor();
    histogram[bucketIndex]+=samples[i];



  }


  for(var i=0;i<histogram.length;++i){
    histogram[i]=(histogram[i]/samplesPerBucket).abs().round();
  }


return histogram;
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


class RadialSeekBar extends StatefulWidget {
  final double seekPercent;
  RadialSeekBar({
    this.seekPercent= 0.0,
});
  @override
  _RadialSeekBarState createState() => _RadialSeekBarState();
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  PolarCoord _startDragCord;
  double _seekPercent=0.0;
  double _startDragPercent=0.0;
  double _currentDragPercent;


  @override
  void initState() {
    super.initState();
    _seekPercent=widget.seekPercent;
  }

  void _onDragStart(PolarCoord cord){
    _startDragCord=cord;
    _startDragPercent=_seekPercent;
  }


  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seekPercent=widget.seekPercent;
  }

  void _onDragEnd(){
    setState(() {
      _seekPercent=_currentDragPercent;
      _currentDragPercent=null;
      _startDragCord=null;
      _startDragPercent=0.0;
    });
  }
  void _onDragUpdate(PolarCoord cord){
    final dragAngle=cord.angle-_startDragCord.angle;
    final dragPercent=dragAngle/(2*pi);
    setState(() {
      _currentDragPercent=((_startDragPercent+dragPercent)%1.0);
    });
  }


  @override
  Widget build(BuildContext context) {
    return RadialDragGestureDetector(
      onRadialDragStart:_onDragStart,
      onRadialDragEnd: _onDragEnd,
      onRadialDragUpdate: _onDragUpdate,
      child: new Container(
        width:double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: new Center(

          child: new Container(
            width: 140.0,
            height: 140.0,
            child: new RadialProgressBar(
              progresspercent:_currentDragPercent ?? _seekPercent,
              trackColor: const Color(0xFFDDDDDD),
              thumbposition: _currentDragPercent ?? _seekPercent,
              progressColor: accentColor,
              thumbColor: lightAccentColor,
              innerPadding: const EdgeInsets.all(10.0),

              child: new ClipOval(
                clipper: new CircleClipper(),
                child: new Image.asset("images/song.png",fit: BoxFit.cover),

              ),
            ),
          ),
        ),
      ),
    );
  }
}


class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double thumbsize;
  final Color thumbColor;
  final double thumbposition;
  final double progresspercent;
  final Widget child;
  final EdgeInsets outerpadding;
  final EdgeInsets innerPadding;


  RadialProgressBar({
   this.trackWidth=3.0,
   this.trackColor=Colors.grey,
    this.progressWidth=5.0,
    this.progressColor=Colors.black,
    this.thumbsize=10.0,
    this.thumbColor=Colors.black,
  this.progresspercent=0.0,
    this.child,
    this.innerPadding=const EdgeInsets.all(0.0),
    this.outerpadding=const EdgeInsets.all(0.0),
    this.thumbposition=0.0,
});


  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {

  EdgeInsets _insetsforPainter(){


    final outerThickness=max(widget.trackWidth,max(widget.progressWidth, widget.thumbsize))/2.0;
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: widget.outerpadding,
      child: new CustomPaint(
        foregroundPainter: new RadialSeekPainter(
        trackColor: widget.trackColor,
          trackWidth: widget.trackWidth,
          progressColor: widget.progressColor,
          progressWidth: widget.progressWidth,
          progresspercent: widget.progresspercent,
          thumbColor: widget.thumbColor,
          thumbposition: widget.thumbposition,
          thumbsize: widget.thumbsize,
        ),
        child: new Padding(
          padding: _insetsforPainter()+widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialSeekPainter extends CustomPainter{
  final double trackWidth;
  final Paint trackpaint;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final Paint progressPaint;
  final double thumbsize;
  final Color thumbColor;
  final double thumbposition;
  final Paint thumbPaint;
  final double progresspercent;
  final Widget child;

  RadialSeekPainter({
    @required this.trackWidth,
    @required this.trackColor,
    @required this.progressWidth,
    @required this.progressColor,
    @required this.thumbsize,
    @required this.thumbColor,
    @required this.progresspercent,
    @required this.thumbposition,
  }) : trackpaint= new Paint()
  ..color=trackColor
  ..style=PaintingStyle.stroke
  ..strokeWidth=trackWidth,
  progressPaint=new Paint()
  ..color=progressColor
  ..style= PaintingStyle.stroke
  ..strokeWidth=progressWidth
  ..strokeCap=StrokeCap.round,

  thumbPaint= new Paint()
  ..color=thumbColor
  ..style=PaintingStyle.fill
  ;

  @override
  void paint(Canvas canvas, Size size) {

    final outerThickness=max(trackWidth,max(progressWidth, thumbsize));
    Size contrainedSize= new Size(size.width-outerThickness, size.height-outerThickness);

    final center=new Offset(size.width/2, size.height/2);
    final radius=min(contrainedSize.width,contrainedSize.height)/2;
    canvas.drawCircle(
        center,
        radius,
        trackpaint);
    final progressAngle=2*pi*progresspercent;
    canvas.drawArc(new Rect.fromCircle(
      center: center,
      radius: radius,
    ),
        -pi/2, progressAngle,
        false,
        progressPaint);
    final thumbangle=2*pi*thumbposition-(pi/2);
    final thumbX=cos(thumbangle)*radius;
    final thumbY=sin(thumbangle)*radius;
    final thumbcircle=new Offset(thumbX,thumbY)+center;
    final thumbradius=thumbsize/2.0;
    canvas.drawCircle(thumbcircle,
        thumbradius,
        thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}




