/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-combined-gestures#sequential-recognition
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';
import { ColorMetrics } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function SequentialCombinedGesturePageBuilder() {
  SequentialCombinedGesturePage();
}

const DOMAIN = 0x0001;
const TAG = 'SequentialCombinedGesture';

@Component
export struct SequentialCombinedGesturePage {
  @Consume pathStack: NavPathStack;
  objectPosition: number[] = [100, 150]; // values: x, y
  area: number[] = [65, 110, 175, 210]; // values: x1, y1, x2, y2
  @State count: number = 0;
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
          Text('Long touch to move object with pan gesture')
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
        // Set the gesture mode to Sequence.
        GestureGroup(GestureMode.Sequence,
          LongPressGesture({ repeat: true })
            .onAction((event: GestureEvent | undefined) => {
              if (event) {
                if (event.repeat) {
                  this.count++;
                }
              }
              hilog.info(DOMAIN, TAG, 'LongPress onAction');
            })
            .onActionEnd(() => {
              hilog.info(DOMAIN, TAG, 'LongPress end');
            }),
          // The pan gesture is triggered when the component is dragged after the long press gesture is recognized.
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
                this.lastOffset = [this.currentEvent ? this.currentEvent.offsetX : 0,
                  this.currentEvent ? this.currentEvent.offsetY : 0]
                this.currentEvent = event
              }
            })
            .onActionEnd(() => {
              this.currentEvent = undefined
            })
        ))
    }
    .onBackPressed(() => {
      return true; // to prevent swiping back
    })
    .hideTitleBar(true)
  }
}