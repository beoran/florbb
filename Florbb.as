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
    public const LEVEL_COUNT  :int  = 2;
    
    public const DIR_UP       :int  = 1;
    public const DIR_RIGHT    :int  = 2;
    public const DIR_DOWN     :int  = 3;
    public const DIR_LEFT     :int  = 4;
    
    public var debug          :Boolean = false;
    public var levelIndex     :int     = 0;
    public var level          :Object  = null;
    
    
    public var levels:Array    = [
      { name : "The Beginning. Click on the orbbs to make them yellow!",
        level: [
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,1,0,
          0,0,0,0,0,0,0,1,0,
          0,0,0,0,0,0,0,1,0,
          0,1,1,1,1,1,0,1,0,
          0,0,0,0,0,0,0,1,0,
          0,0,0,0,0,0,0,1,0,
          0,0,0,0,0,0,0,1,0,
          0,0,0,0,0,0,0,0,0
        ]
      },
      { name : "Go on! Orbs influence each other.",
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
      }
    ];
  
    public var field:Array  = [];
    // text fields
    public var orbbText:TextField   = new TextField();
    public var levelText:TextField  = new TextField();
    
    // handle for timeout
    public var timeout : *;
    
    
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
            orbbs.text.text       = "" + tile;
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
          var text:TextField = new TextField();
          blue.x = xx * 32 + xoff;
          blue.y = yy * 32 + yoff;
          yell.x = xx * 32 + xoff;
          yell.y = yy * 32 + yoff;
          yell.visible  = false;
          blue.visible  = false;
          text.text = "?";
          text.x = blue.x;
          text.y = blue.y;
          
          if(field[yy] == null) { field[yy] = []; }
          field[yy][xx] = { blue: blue, yellow : yell, text : text };
          addChild(blue);
          addChild(yell);
          addChild(text);
        }
      }
      
      loadLevelIndex(0);
      
      orbbBlue.x   = 80;
      orbbBlue.y   = 50;
      addChild(orbbBlue);
      orbbText.autoSize = TextFieldAutoSize.LEFT;
      orbbText.antiAliasType = AntiAliasType.ADVANCED;
      orbbText.textColor = 0xFFFFFF;
      orbbText.text = "Welcome to Florbb! Click on the orbs to make them all yellow!";
     
      addChild(orbbText);
      levelText.autoSize = TextFieldAutoSize.LEFT;
      levelText.antiAliasType = AntiAliasType.ADVANCED
      levelText.y = 16;
      levelText.x = 0;
      levelText.textColor = 0xFFFFFF;
      addChild(levelText);
      
      stage.addEventListener(MouseEvent.CLICK, clickRespond);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, keyRespond);      
      // half volume
      SoundMixer.soundTransform = new SoundTransform(0.5, 0);
      // music.play(0, int.MAX_VALUE); // Play the music in loops.
    }
    
    // levels up at the end of a slevel
    public function levelUp() {
      levelIndex += 1;
      // we have reached the last level
      if(levelIndex >= LEVEL_COUNT) {
        orbbText.text = "Congratulations , you won the game!"
        orbbText.textColor = 0xFFFF88;
        levelText.text = "Wel done!"
        levelText.textColor = 0xFFFF88;
      } else {
        levelText.text = "Loading next level!"
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
    
    // returns true if level was won, false if not, or if not valid x and y
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
      return won();
    }
        
    public function clickRespond(e:MouseEvent):void
    {
      var xx:int;
      var yy:int;
      var xoff:int = (stage.stageWidth  / 2) - ((32*FIELD_WIDTH)  / 2);
      var yoff:int = (stage.stageHeight / 2) - ((32*FIELD_HEIGHT) / 2);
      // don't allow further play if already won.
      if (won()) return;
      // ourExampleText.text = "Press keys";      
      xx = (mouseX - xoff) / 32;
      yy = (mouseY - yoff) / 32;
      orbbText.text = "Click xx: " + xx + " yy: " + yy + " mx: " + 
                      mouseX + " my: " + mouseY;
      if (playAt(xx, yy)) {
        beep.play(); // Play a beep
      }
      redrawLevel();
      if(won()) {
        orbbText.text = "Congratulations , you cleared this level!"
        applause.play();
        // set level up to happen in a few seconds...
        timeout = setTimeout(levelUp, 2000);
      }
    }

    public function keyRespond(event:KeyboardEvent):void
    {
      if(event.keyCode == 32) { // pressing spacebar?
        beep.play(); // beep!
      }
      // ourExampleText.text = "Key code: " + event.keyCode;
    }
  }
}