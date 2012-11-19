package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ParallelLines extends Sprite
	{
		protected static const ZERO_POINT : Point = new Point();

		/* the mouse positions as originally read */
		protected var rawPoints : Vector.<Point> = new Vector.<Point>();
		
		/* if smoothLine is set to true, this will be the positioned, smoothed to produce a more pleasing shape */
		protected var points : Vector.<Point> = new Vector.<Point>();
		
		/* flag to make sure we only draw when the mouse is down */
		protected var isMouseDown : Boolean = false;
		
		/* set to false, to just draw the raw mouse positions */
		protected var smoothLine : Boolean = true;
		
		/* set to true if you wish to draw the centre line */
		protected var drawCentreLine : Boolean = false;
		
		/* the distance from the center line, to it's parallel nieghboors */
		protected var parallelLineDistance : Number = 10;
		
		/* the minimum distance between each point on the line */
		protected var minimumLineDistance : Number = 3;

		/* the shape we are drawing the current line to. */
		protected var canvas : Shape;
		
		/* the current line color */
		protected var currentLineColour : uint;
		
		public function ParallelLines()
		{
			if( stage ) init();
			else addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		protected function init(e:Event=null):void
		{
			addEventListener(Event.ENTER_FRAME, handleEnterFrame );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown );
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp );
		}
		
		protected function drawPoints():void
		{
			canvas.graphics.clear();
			canvas.graphics.lineStyle( 2, currentLineColour );
			
			
			for( var i:int=0; i<points.length-1; i++ )
			{
				var point : Point = points[i];
				var nextPoint : Point = points[i+1];
				/* calculate the direction of the current point from the last point */
				var direction : Point = point.subtract( nextPoint );
				/* 
				   set the length of the direction to be the distance 
				   that the parallel lines should be from the centre 
				*/
				direction.normalize( parallelLineDistance );
				
				/* work out the tangients to the direction, and add them to the current position */
				var leftPoint : Point = new Point( direction.y, -direction.x ).add( point );
				var rightPoint : Point = new Point( -direction.y, direction.x ).add( point );
				
				if( lastLeftPoint && lastRightPoint ){	
					
					if( drawCentreLine ) drawLine( lastPoint, point );
					drawLine( lastLeftPoint, leftPoint );
					drawLine( lastRightPoint, rightPoint );
				}else{
					drawLine( leftPoint, rightPoint );
				}
				
				var lastLeftPoint : Point = leftPoint;
				var lastRightPoint : Point = rightPoint;
				var lastPoint : Point = point;
			}
			
			if( leftPoint && rightPoint ) drawLine( leftPoint, rightPoint );
		}
		
		protected function drawLine( p1 : Point, p2:Point ):void
		{
			canvas.graphics.moveTo( p1.x, p1.y );
			canvas.graphics.lineTo( p2.x, p2.y );
		}
		
		protected function smoothPoints():void
		{
			var previousPoint : Point;
			var point : Point;
			var nextPoint : Point;
			var smoothedPoint : Point;

			var nextIndex : int;
			var previousIndex: int;
			
			for( var i:int=Math.max( points.length-1, 0 ); i<rawPoints.length; i++ )
			{
				nextIndex = i+1;
				previousIndex = i-1;
				
				/* if out of range, clamp the next and previous index */
				if( nextIndex >= rawPoints.length ) nextIndex = i;
				if( previousIndex < 0 ) previousIndex = i;
				
				previousPoint = rawPoints[previousIndex];
				point = rawPoints[i];
				nextPoint = rawPoints[nextIndex];

				/* caluclate average position of previous current and next position */
				smoothedPoint = Point.interpolate( new Point().add( previousPoint ).add( point ).add( nextPoint ), ZERO_POINT, 1/3 );
				
				/* if the position doesn't exist create it, else overwrite it */
				if( i == points.length ) points.push( smoothedPoint );
				else points[i] = smoothedPoint;
			}
		}
		
		protected function copyPoints():void
		{
			points = rawPoints.concat();
		}
		
		protected function clearPoints():void
		{
			rawPoints.splice( 0, rawPoints.length );
			points.splice( 0, points.length );
		}
		
		protected function handleEnterFrame(e:Event):void
		{
			if( ! isMouseDown ) return;
			
			var lastPoint : Point;
			var currentPoint : Point = new Point( mouseX, mouseY );
			
			if( points.length > 0 ) lastPoint = points[ points.length - 1 ];
			
			/* if there isn't a last point, or the last point is greather than threshold */
			if( !lastPoint || Point.distance( lastPoint, currentPoint ) > minimumLineDistance )
			{
				rawPoints.push( currentPoint );
				
				if( smoothLine )
					smoothPoints();
				else
					copyPoints();
				
				drawPoints();
				
			}
				
		}
		
		protected function handleMouseDown(e:Event):void
		{
			isMouseDown = true;
			addChild( canvas = new Shape() );
			currentLineColour = uint( Math.random() * 0xffffff );
			clearPoints();
		}
		
		protected function handleMouseUp(e:Event):void
		{
			isMouseDown = false;
			canvas = null;
		}
	}
}