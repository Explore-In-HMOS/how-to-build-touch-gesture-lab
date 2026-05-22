/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-single-gesture
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function PinchGesturePageBuilder() {
  PinchGesturePage();
}

@Component
export struct PinchGesturePage {
  @Consume pathStack: NavPathStack;
  @State scaleValue: number = 1;
  @State pinchValue: number = 1;
  @State eventScale: number = 1;
  @State pinchX: number = 0;
  @State pinchY: number = 0;
  @State isPinching: boolean = false;
  private backOptions: ArcButtonOptions = new ArcButtonOptions({
    label: 'back',
    position: ArcButtonPosition.TOP_EDGE,
    onClick: () => {
      this.pathStack.clear();
    }
  });

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Column()
            .backgroundColor(Color.Blue)
            .width(100)
            .height(100)
            .scale({ x: this.scaleValue, y: this.scaleValue, z: 1 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .gesture(
          // Bind a two-finger pinch gesture to the component.
          PinchGesture({ fingers: 2 })
            .onActionStart((event: GestureEvent | undefined) => {
              console.info('Pinch start');
            })
            .onActionUpdate((event: GestureEvent | undefined) => {
              if (event) {
                this.isPinching = true
                this.eventScale = event.scale;
                this.scaleValue = this.pinchValue * event.scale;
                this.pinchX = event.pinchCenterX
                this.pinchY = event.pinchCenterY
              }
            })
            .onActionEnd(() => {
              this.isPinching = false
              this.pinchValue = this.scaleValue
              console.info('Pinch end');
            })
        )

        Column({ space: 10 }) {
          ArcButton({ options: this.backOptions })
          Text(this.isPinching ?
            `event scale: ${this.eventScale.toFixed(2)}\n(${this.pinchX.toFixed(2)}, ${this.pinchY.toFixed(2)})` :
            'No pinch')
          Blank()
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .height('100%')
      .width('100%')
    }
    .onBackPressed(() => {
      return true; // to prevent swiping back
    })
    .hideTitleBar(true)
  }
}