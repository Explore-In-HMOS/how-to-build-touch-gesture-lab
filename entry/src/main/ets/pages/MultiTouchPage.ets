/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-interaction-development-guide-touch-screen
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ArcButton, ArcButtonOptions, ArcButtonPosition, ColorMetrics } from '@kit.ArkUI';

const TAG = '[MultiTouch]';
const DOMAIN = 0xF811;

@Builder
export function MultiTouchPageBuilder() {
  MultiTouchPage();
}

@Component
export struct MultiTouchPage {
  @Consume pathStack: NavPathStack;
  private currentFingerCount: number = 0;
  @State private allFingers: TouchObject[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private backOptions: ArcButtonOptions = new ArcButtonOptions({
    label: 'back',
    position: ArcButtonPosition.TOP_EDGE,
    onClick: () => {
      this.pathStack.clear();
    }
  });

  private drawFingers() {
    // clear screen
    this.context.clearRect(0, 0, this.context.width, this.context.height)

    this.context.strokeStyle = ColorMetrics.rgba(255, 255, 255).color;
    for (const finger of this.allFingers) {
      const region = new Path2D();
      const arcRadius = 25;
      region.arc(finger.displayX, finger.displayY, arcRadius, 0, 2 * Math.PI);
      this.context.stroke(region);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Canvas(this.context)
            .width('100%')
            .height('100%')
            .backgroundColor($r('app.color.start_window_background_dark'))
            .onReady(() => {
              this.drawFingers();
            })
          Column({ space: 5 }) {
            Text(this.allFingers.length > 0 ? `${this.allFingers.length} touch` : 'No touch')
              .fontSize(20)

            ForEach(this.allFingers, (finger: TouchObject) => {
              Text(`id: ${finger.id}, (${finger.windowX.toFixed(2)}, ${finger.windowY.toFixed(2)})`)
            }, (finger: TouchObject) => `${finger.displayX.toString()}-${finger.displayY.toString()}`)
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
      }
      .height('100%')
      .width('100%')
      .onTouch((event: TouchEvent) => {
        if (event.source !== SourceType.TouchScreen) {
          return;
        }
        // Clear the array.
        this.allFingers.splice(0, this.allFingers.length);

        // Obtain all touch point information from the event.
        const allFingers = event.touches;
        if (allFingers.length > 0 && this.currentFingerCount === 0) {
          // The first finger is pressed.
          hilog.info(DOMAIN, TAG, 'fingers start to press down');
          this.currentFingerCount = allFingers.length;
        }
        if (allFingers.length !== 0) {
          for (const finger of allFingers) {
            this.allFingers.push(finger);
          }
        }
        if (event.type === TouchType.Up && event.touches.length === 1) {
          // All fingers are lifted.
          hilog.info(DOMAIN, TAG, 'all fingers already up');
          this.currentFingerCount = 0;
          this.allFingers.splice(0, this.allFingers.length);
        }
        this.drawFingers();
      })
    }
    .onBackPressed(() => {
      return true; // to prevent swiping back
    })
    .hideTitleBar(true)
  }
}