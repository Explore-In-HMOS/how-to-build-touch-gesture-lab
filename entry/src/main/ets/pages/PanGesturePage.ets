/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-single-gesture
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';
import { ColorMetrics } from '@kit.ArkUI';

@Builder
export function PanGesturePageBuilder() {
  PanGesturePage();
}

@Component
export struct PanGesturePage {
  @Consume pathStack: NavPathStack;
  objectPosition: number[] = [100, 150]; // values: x, y
  area: number[] = [65, 100, 175, 200]; // values: x1, y1, x2, y2
  private lastOffset: number[] = [0, 0]
  @State currentEvent: GestureEvent | undefined = undefined;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private backOptions: ArcButtonOptions = new ArcButtonOptions({
    label: 'back',
    position: ArcButtonPosition.TOP_EDGE,
    onClick: () => {
      this.pathStack.clear();
    }
  });

  private handlePanUpdate(event: GestureEvent) {
    this.objectPosition[0] += (event.offsetX - this.lastOffset[0]) / 2
    this.objectPosition[1] += (event.offsetY - this.lastOffset[1]) / 2

    // stay on area
    this.objectPosition[0] = this.objectPosition[0] > this.area[2] ? this.area[2] :
      (this.objectPosition[0] < this.area[0] ? this.area[0] : this.objectPosition[0])
    this.objectPosition[1] = this.objectPosition[1] > this.area[3] ? this.area[3] :
      (this.objectPosition[1] < this.area[1] ? this.area[1] : this.objectPosition[1])
  }

  private drawObject() {
    this.context.clearRect(0, 0, this.context.width, this.context.height)
    this.context.strokeStyle = ColorMetrics.rgba(255, 255, 255).color;

    const region = new Path2D();
    const arcRadius = 10;
    region.arc(this.objectPosition[0], this.objectPosition[1], arcRadius, 0, 2 * Math.PI);
    this.context.stroke(region);

    const region2 = new Path2D();
    region2.rect(this.area[0], this.area[1], this.area[2] - this.area[0], this.area[3] - this.area[1]);
    this.context.stroke(region2);
  }

  build() {
    NavDestination() {
      Stack() {
        Canvas(this.context)
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.start_window_background_dark'))
          .onReady(() => {
            this.drawObject();
          })
        Column() {
          Text(this.currentEvent ?
            `offset: (${this.currentEvent?.offsetX.toFixed(2)}, ${this.currentEvent?.offsetY.toFixed(2)})` :
            'No touch')
            .fontSize(20)
            .margin({ bottom: 70 })
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Column() {
          ArcButton({ options: this.backOptions })
          Blank()
        }
        .width('100%')
        .height('100%')
      }
      .gesture(
        PanGesture()
          .onActionStart(() => {
            console.info('Pan start');
            this.lastOffset = [0, 0]
          })
          .onActionUpdate((event: GestureEvent) => {
            this.drawObject()
            if (event.source === SourceType.TouchScreen) {
              console.info('finger move triggered PanGesture')
              this.handlePanUpdate(event)
              this.lastOffset =
                [this.currentEvent ? this.currentEvent.offsetX : 0, this.currentEvent ? this.currentEvent.offsetY : 0]
              this.currentEvent = event
            }
          })
          .onActionEnd(() => {
            this.currentEvent = undefined
          })
      )
    }
    .onBackPressed(() => {
      return true; // to prevent swiping back
    })
    .hideTitleBar(true)
  }
}