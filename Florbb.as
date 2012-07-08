/*
Florbb is copyright Bjorn De Meyer, 2012. 

Licenced under the ZLIB License.

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.

*/

package {
  import flash.display.Sprite;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.AntiAliasType;
  import flash.display.Bitmap;
  import flash.events.MouseEvent;
  import flash.events.KeyboardEvent;
  // Imports for sound effects
  import flash.media.Sound; 
  import flash.media.SoundChannel; 
  import flash.media.SoundMixer; 
  import flash.media.SoundTransform;
  import flash.display.StageQuality;
  import flash.utils.ByteArray;
  import flash.utils.setTimeout;
  import spark.components.CheckBox;
  import PlayField;
  
  [SWF(width="640", height="480", backgroundColor="#000044")]
    
  
  public class Florbb extends Sprite
  {  
    public const FIELD_WIDTH  :int  = 9;
    public const FIELD_HEIGHT :int  = 9;
    public const FIELD_XOFFSET:int  = 128;
    public const FIELD_YOFFSET:int  = 128;
    
    public const LEVEL_EMPTY  :int  = 0;
    public const LEVEL_BLUE   :int  = 1;
    public const LEVEL_YELLOW :int  = 2;
    
    // amount of levels
    public const LEVEL_COUNT  :int  = 4;
    
    public const DIR_UP       :int  = 1;
    public const DIR_RIGHT    :int  = 2;
    public const DIR_DOWN     :int  = 3;
    public const DIR_LEFT     :int  = 4;
    public const MUSIC_X      :int  = 550;
    public const MUSIC_Y      :int  = 350;
    
    public var debug          :Boolean = false;
    public var levelIndex     :int     = 0;
    public var level          :Object  = null;
    
    
    public var levels:Array    = [
      { name : "The Beginning. Click on the orbbs to make them yellow!",
        level: [
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,1,0,0,0,0,
          1,1,1,1,1,1,1,1,1,
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,1,0,0,0,0
        ]
      },
      { name : "Go on! Clicked orbbs influence each other horizontally and verticaly.",
        level: [
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,1,1,1,0,0,0,
          0,0,0,1,1,1,0,0,0,
          0,0,0,1,1,1,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0
        ]
      },
      { name : "Keep going in the right way!",
        level: [
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,1,0,0,
          1,1,1,1,1,1,1,1,0,
          1,1,1,1,1,1,1,1,1,
          1,1,1,1,1,1,1,1,0,
          0,0,0,0,0,0,1,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0
        ]
      },
      { name : "Starred crossroads.",
        level: [
          0,0,0,0,1,0,0,0,0,
          0,0,0,1,1,1,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,1,0,0,1,0,0,1,0,
          1,1,1,1,1,1,1,1,1,
          0,1,0,0,1,0,0,1,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,1,1,1,0,0,0,
          0,0,0,0,1,0,0,0,0
        ]
      }
    ];
  
    public var field:Array  = [];
    // text fields
    public var orbbText:TextField   = new TextField();
    public var levelText:TextField  = new TextField();
    public var musicText:TextField  = new TextField();
    
    // handle for timeout
    public var timeout : *;
    
    // checkboxes for music and sound
    public var musicCB : CheckBox = new CheckBox();
    public var soundCB : CheckBox = new CheckBox();
    
    
    // Embed images
    [Embed(source="/embed/orbb_blue.png")]
    public var orbbBlueData   : Class;
    [Embed(source="/embed/orbb_yellow.png")]
    public var orbbYellowData : Class;
    [Embed(source="/embed/background.jpg")]
    public var backgroundData : Class;
    
    // Load images
    public var orbbBlue:Bitmap    = new orbbBlueData() as Bitmap;
    public var orbbYellow:Bitmap  = new orbbYellowData() as Bitmap;
    public var background:Bitmap  = new backgroundData() as Bitmap;

    // Embed sounds and music.
    [Embed(source="/embed/beep.mp3")]     // filename of sound to load
    public var beepData:Class;            // code name for that filename
    [Embed(source="/embed/applause.mp3")] 
    public var applauseData:Class;
    [Embed(source="/embed/music.mp3")] 
    public var musicData:Class;
    // load sounds and music
    public var beep:Sound      = new beepData() as Sound;
    public var music:Sound      = new musicData() as Sound;
    public var applause:Sound   = new applauseData() as Sound;
    
    // channel for the music 
    public var musicChannel:SoundChannel  = null;
    
    // used to clone the level data
    public function clone(source:Object ):* {
      var myBA:ByteArray = new ByteArray();
      myBA.writeObject( source );
      myBA.position = 0;
      return( myBA.readObject() );
    }
    
    // gets the tile from the current active level
    // level must have been loaded correctly and x and y must be in range
    public function getTile(xx:int, yy:int) : int {
      return level.level[(yy*FIELD_WIDTH)+xx];
    }
    
    // sets the tile in the current active level
    // level must have been loaded correctly and x and y must be in range
    public function setTile(xx:int, yy:int, tile:int) : int {
      return level.level[(yy*FIELD_WIDTH)+xx] = tile;
    }
    
    // toggles the tile in the current active level
    public function flipTile(xx:int, yy:int) : int {
      var tile:int = getTile(xx, yy);
      // don't toggle empty
      if (tile == LEVEL_EMPTY) { return LEVEL_EMPTY;                 }
      if (tile == LEVEL_BLUE)  { return setTile(xx, yy, LEVEL_YELLOW); }
      if (tile == LEVEL_YELLOW){ return setTile(xx, yy, LEVEL_BLUE);   }
      // if not yellow or blue, don't know what to do
      return tile;
    }
    
    
    
    public function redrawLevel() : void {
      var xx:int;
      var yy:int;
      levelText.text = level.name;
      for (yy = 0; yy < FIELD_HEIGHT; yy++)   {
        for(xx = 0; xx < FIELD_WIDTH; xx++)   {
          var orbbs:Object      = field[yy][xx];
          var tile:int          = getTile(xx, yy);
          orbbs.blue.visible    = ( tile == LEVEL_BLUE   );
          orbbs.yellow.visible  = ( tile == LEVEL_YELLOW );
          if(debug) {
            orbbs.text.text     = "" + tile;
          }
        }
      }
    }
    
    public function loadLevelIndex(index:int) : Object {
      var aid:Object  = null;
      aid   = levels[index];
      if(!aid) return null;
      level = clone(aid);
      redrawLevel();
      return level;
    }

    public function Florbb()
    { 
      var xx:int;
      var yy:int;
      var xoff:int = (stage.stageWidth  / 2) - ((32*FIELD_WIDTH)  / 2);
      var yoff:int = (stage.stageHeight / 2) - ((32*FIELD_HEIGHT) / 2);
      
      // width   = 640;
      // height  = 480;
      // best stage quality
      stage.quality = StageQuality.BEST;
      // add background image
      addChild(background);
      // set up bitmaps
      for (yy = 0; yy < FIELD_HEIGHT; yy++)
      {
        for(xx = 0; xx < FIELD_WIDTH; xx++)
        {
          var blue:Bitmap = new orbbBlueData() as Bitmap;
          var yell:Bitmap = new orbbYellowData() as Bitmap;
          // var text:TextField = new TextField();
          blue.x = xx * 32 + xoff;
          blue.y = yy * 32 + yoff;
          yell.x = xx * 32 + xoff;
          yell.y = yy * 32 + yoff;
          yell.visible  = false;
          blue.visible  = false;
          // text.text = "?";
          // text.x = blue.x;
          // text.y = blue.y;
          
          if(field[yy] == null) { field[yy] = []; }
          field[yy][xx] = { blue: blue, yellow : yell };
          addChild(blue);
          addChild(yell);
          // addChild(text);
        }
      }
      
      loadLevelIndex(0);
      
      orbbText.autoSize = TextFieldAutoSize.LEFT;
      orbbText.antiAliasType = AntiAliasType.ADVANCED;
      orbbText.textColor = 0xFFFFFF;
      orbbText.text = "Welcome to Florbb! Copyright Bjorn De Meyer, 2012. Can be used freely under the ZLIB License.";
     
      addChild(orbbText);
      
      levelText.autoSize = TextFieldAutoSize.LEFT;
      levelText.antiAliasType = AntiAliasType.ADVANCED
      levelText.y = 16;
      levelText.x = 0;
      levelText.textColor = 0xFFFFFF;
      addChild(levelText);
      
      musicText.autoSize  = TextFieldAutoSize.LEFT;
      musicText.antiAliasType = AntiAliasType.ADVANCED;
      musicText.textColor = 0xFFFFFF;
      musicText.text      = "Music ON";
      musicText.border    = true;
      musicText.x         = MUSIC_X; musicText.y = MUSIC_Y;
      addChild(musicText);
      
      
      stage.addEventListener(MouseEvent.CLICK, clickRespond);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, keyRespond);
      // half volume
      SoundMixer.soundTransform = new SoundTransform(0.5, 0);
      toggleMusic(); // Play the music in loops.
      
      musicText.addEventListener(MouseEvent.CLICK, toggleMusic);
      stage.addChild(musicCB);
      
      
      
    }
    
 
    public function toggleMusic():void { 
      if (musicChannel) {
          musicChannel.stop();
          musicChannel    = null;
          musicText.text  = "Music OFF";
      } else  {
        musicChannel = music.play(0, int.MAX_VALUE); // Play the music in loops.
        musicText.text  = "Music ON";
      }
    }
    
    // levels up at the end of a slevel
    public function levelUp() : void {
      // Check if we we have reached the last level
      if((levelIndex + 1) >= levels.length) {
        orbbText.text = "Congratulations , you won the game!"
        orbbText.textColor = 0xFFFF88;
        levelText.text = "Well done!"
        levelText.textColor = 0xFFFF88;
      } else {
        levelIndex += 1;
        levelText.text = "Loading next level!"
        orbbText.text  = "Make all orbbs yellow!"
        loadLevelIndex(levelIndex);
      }
    }
    
    // returns true if current level was won
    public function won() : Boolean {
      var xx:int;
      var yy:int;
      for (yy = 0; yy < FIELD_HEIGHT; yy++)   {
        for(xx = 0; xx < FIELD_WIDTH; xx++)   {
          var tile:int          = getTile(xx, yy);
          if (( tile != LEVEL_EMPTY) && ( tile != LEVEL_YELLOW )) return false;
        }
      }
      return true;
    }
    
    // fills the field recursively according to the rules in the given direction
    public function playRecurse(xx:int, yy:int, dir:int) : Boolean {
      // done if out of bounds
      if (xx < 0) return false;
      if (yy < 0) return false;
      if (xx >= FIELD_WIDTH) return false;
      if (yy >= FIELD_HEIGHT) return false;
      // we're done if flipping an empty tile;
      if(flipTile(xx, yy) == LEVEL_EMPTY) return false;
      switch(dir) { 
        case DIR_UP:
          return playRecurse(xx     , yy - 1, dir);
        case DIR_RIGHT:
          return playRecurse(xx + 1 , yy    , dir);
        case DIR_DOWN:
          return playRecurse(xx     , yy + 1, dir);
        case DIR_LEFT:
          return playRecurse(xx - 1 , yy    , dir);
        default:
          return false;
      }     
      return false; // can't happen
    }
    
    // returns true if cell was played, false if not
    public function playAt(xx:int, yy:int) : Boolean {
      if (xx < 0) return false;
      if (yy < 0) return false;
      if (xx >= FIELD_WIDTH) return false;
      if (yy >= FIELD_HEIGHT) return false;
      // If clicked on an emptytile nothing happens
      if (flipTile(xx, yy) == LEVEL_EMPTY) return false;
      // Otherwse recursively play up, down, left and right
      playRecurse(xx + 1, yy, DIR_RIGHT);
      playRecurse(xx - 1, yy, DIR_LEFT);
      playRecurse(xx, yy + 1, DIR_DOWN);
      playRecurse(xx, yy - 1, DIR_UP);
      return true;
    }
        
    public function clickRespond(e:MouseEvent):void
    {
      var xx:int;
      var yy:int;
      var xoff:int = (stage.stageWidth  / 2) - ((32*FIELD_WIDTH)  / 2);
      var yoff:int = (stage.stageHeight / 2) - ((32*FIELD_HEIGHT) / 2);
      // if clicked in the corner toggle music
      if((mouseX > MUSIC_X) && (mouseY > MUSIC_Y)) {
        toggleMusic();
        return;
      }
      
      
      // don't allow further play if already won.
      if (won()) return;
      // ourExampleText.text = "Press keys";
      xx = (mouseX - xoff) / 32;
      yy = (mouseY - yoff) / 32;
      // orbbText.text = "Click xx: " + xx + " yy: " + yy + " mx: " + 
      //                  mouseX + " my: " + mouseY;
      if (playAt(xx, yy)) {
        playSound(beep); // Play a beep if a cell was played
      }
      redrawLevel();
      if(won()) {
        orbbText.text = "Congratulations , you cleared this level!"
        playSound(applause);
        // set level up to happen in a few seconds...
        timeout = setTimeout(levelUp, 2000);
      }
    }
    
    // plays a sound, but only if the music is playing
    public function playSound(sound:Sound) : void {
      if(musicChannel == null) return ;
      sound.play();
    }

    public function keyRespond(event:KeyboardEvent):void
    {
      if(event.keyCode == 32) { // pressing spacebar?
      }
      // ourExampleText.text = "Key code: " + event.keyCode;
    }
  }
}