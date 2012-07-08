package {
  import flash.display.Sprite;
  import flash.text.TextField;
  import flash.display.Bitmap;
  import flash.events.MouseEvent;
  import flash.events.KeyboardEvent;
  import flash.media.Sound; // needed for sound effects
  import PlayField;
  

    
  
  public class GameCore extends Sprite
  {  
    public const FIELD_WIDTH:int   = 9;
    public const FIELD_HEIGHT:int  = 9;
    
    public var levels:Array  = [
      { name : "Beginning",
        level: [
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,1,1,1,0,0,0,
          0,0,0,0,1,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0
        ]
      },
      { name : "Next",
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
  
    public var field:Array  = null;
    public var ourExampleText:TextField = new TextField();

    [Embed(source="/happyball.png")]
    public var ballImage:Class;
    public var ballBMP:Bitmap = new ballImage() as Bitmap;

    [Embed(source="/good.mp3")] // filename of sound to load
    public var clickSound:Class; // code name for that filename
    
     // This is how we'll keep track of the sound from "clickSound"
    public var clickSND:Sound = new clickSound() as Sound;
    
    /* 2 notes about how sound is loaded:
         1- It's almost identical to how bitmaps are loaded
         2- Note that using Sound and SND in the sound variable name 
           (or using Image and BMP in the bitmap variable names) is
           only my own convention. It isn't necessary for the code
           to work. If we change "clickSound" in both places to say
           "CalloohCallay", and change "clickSND" in all locations
           to read "FrumiousBandersnatch" everything will work 
            the same. */

    public function GameCore()
    {      
      ballBMP.x = 80;
      ballBMP.y = 50;
      addChild(ballBMP);

      ourExampleText.text = "Sounds!";
      addChild(ourExampleText);
      
      stage.addEventListener(MouseEvent.CLICK, clickRespond);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, keyRespond);      
    }
        
    public function clickRespond(e:MouseEvent):void
    {
      ourExampleText.text = "Press keys";
      clickSND.play(); // bloop!
      ballBMP.x = mouseX;
      ballBMP.y = mouseY;
    }

    public function keyRespond(event:KeyboardEvent):void
    {
      if(event.keyCode == 32) { // pressing spacebar?
        clickSND.play(); // bloop!
      }
      ourExampleText.text = "Key code: " + event.keyCode;
    }
  }
}