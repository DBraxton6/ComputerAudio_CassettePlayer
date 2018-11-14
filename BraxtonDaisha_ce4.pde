import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;

SamplePlayer music;
SamplePlayer musicPlay;
SamplePlayer musicStop;
SamplePlayer musicFF;
SamplePlayer musicRewind;
SamplePlayer musicReset;
SamplePlayer tapeStop;
Glide musicRateGlide; // control playback rate of music SamplePlayer (i.e. play, FF, Rewind)
double musicLength; // used to store length of music sample in milliseconds
Bead musicEndListener; // used to detect end/beginning of music playback, rewind, FF


//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()

  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  music = getSamplePlayer("music.wav", false); // make sure killOnEnd = false
  musicPlay = getSamplePlayer("gameJump.wav");
  musicStop = getSamplePlayer("marioCoin.wav");
  musicFF = getSamplePlayer("marioSlide.wav");
  musicRewind = getSamplePlayer("gameSound.wav");
  musicReset = getSamplePlayer("powerUp.wav");
  
  musicRateGlide = new Glide(ac, 0, 250); // initially, set rate to 0, otherwise, music will play when you start the sketch
  music.setRate(musicRateGlide); // pause music - equivalent to music.pause(true);
  musicLength = music.getSample().getLength(); // store length of music sample in ms
  
  musicPlay.pause(true);
  musicStop.pause(true);
  musicFF.pause(true);
  musicRewind.pause(true);
  musicReset.pause(true);
  
  ac.out.addInput(music);
  ac.out.addInput(musicPlay);
  ac.out.addInput(musicStop);
  ac.out.addInput(musicFF);
  ac.out.addInput(musicRewind);
  ac.out.addInput(musicReset);
 
// create an endListener event handler to detect when the end or beginning of the music sample has been reached
musicEndListener =  new Bead() {
        public void messageReceived(Bead message) {
            // remove this endListener to prevent its firing over and over due to playback position bugs in Beads
            music.setEndListener(null);

            // Reset playback position to end or beginning of sample to work around Beads bug
            //  where playback position can go past the end points of the sample.

 
            // if playing or fast-forwarding and the playback head is at the end of the music sample
            if (musicRateGlide.getValue() > 0 && music.getPosition() >= musicLength) {
              tapeStop.start(0);  
              musicRateGlide.setValueImmediately(0); // pause music, use setValueImmediately() instead of setValue()
              music.setToEnd(); // reset playback position to the end of the sample, ready to rewind
            }

 
            // if rewinding and the playback position is at the start of the music sample
            if (musicRateGlide.getValue() < 0 && music.getPosition() <= 0.0) {
                musicRateGlide.setValueImmediately(0); // pause music by setting the playback rate to zero
                music.reset(); // reset playback position to the start of the sample
            }
        }
    };
    
  ac.start();

  p5.addButton("Play")
    .setPosition(width / 2 - 50, 80)
    .setCaptionLabel("Play");
    
  p5.addButton("Stop")
    .setPosition(width / 2 - 50, 100)
    .setCaptionLabel("Stop");
    
  p5.addButton("FastFwrd")
    .setPosition(width / 2 - 50, 120)
    .setCaptionLabel("Fast Forward");
    
  p5.addButton("Rewind")
    .setPosition(width / 2 - 50, 140)
    .setCaptionLabel("Rewind");

  p5.addButton("Reset")
    .setPosition(width / 2 - 50, 160)
    .setCaptionLabel("Reset");
    
}

// Button handler for Play button
public void Play(int value)
{
    // if we haven’t reached the end of the tape yet, setEndListener and update playback rate
    if (music.getPosition() < musicLength) {
        music.setEndListener(musicEndListener);
        // play music forward at normal speed
        musicRateGlide.setValue(1);
    }
    // Play your ‘Play’ button sound effect
    musicPlay.start(0);
}

public void Stop(int value)
{
    musicStop.start(0);
    musicRateGlide.setValue(0);
}

public void FastFwrd(int value)
{
    if (music.getPosition() < musicLength) {
        if (music.getEndListener() == null) {
          music.setEndListener(musicEndListener);
        }
        musicRateGlide.setValue(8.25);
    }

    // Play your ‘FastFwrd’ button sound effect
    musicFF.start(0);
}

public void Rewind(int value)
{
    if (music.getPosition() < musicLength) {
        if (music.getEndListener() == null) {
          music.setEndListener(musicEndListener);
        }
        musicRateGlide.setValue(-8.25);
    }

    // Play your ‘Rewind’ button sound effect
    musicRewind.start(0);
}

public void Reset(int value)
{
    // if we haven’t reached the end of the tape yet, setEndListener and update playback rate
    if (music.getPosition() < musicLength) {
        music.setEndListener(musicEndListener);
        // play music forward at normal speed
        musicRateGlide.setValue(1);
        music.reset();
    }

    // Play your ‘Reset’ button sound effect
    musicReset.start(0);
}

// Main draw loop - normally only used for immediate mode graphics rendering
void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
