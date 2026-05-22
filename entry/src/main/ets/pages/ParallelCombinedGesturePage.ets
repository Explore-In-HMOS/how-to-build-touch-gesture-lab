/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-combined-gestures#parallel-recognition
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function ParallelCombinedGesturePageBuilder() {
  ParallelCombinedGesturePage();
}

@Component
export struct ParallelCombinedGesturePage {
  @Consume pathStack: NavPathStack;
  // states for rotation
  @State angle: number = 0;
  @State eventAngle: number = 0;
  @State rotateValue: number = 0;
  // states for pinch
  @State scaleValue: number = 1;
  @State pinchValue: number = 1;
  @State pinchX: number = 0;
  @State pinchY: number = 0;
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
            .margin({ top: 10 })
            .width(80)
            .height(80)
            .rotate({ angle: this.angle })
            .scale({ x: this.scaleValue, y: this.scaleValue, z: 1 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .gesture(
          GestureGroup(GestureMode.Parallel,
            RotationGesture()
              .onActionStart((event: GestureEvent | undefined) => {
                console.info('RotationGesture is onActionStart')
              })
              // When the rotation gesture is triggered, obtain the rotation angle and apply it to the component.
              .onActionUpdate((event: GestureEvent | undefined) => {
                if (event) {
                  this.eventAngle = event.angle;
                  this.angle = this.rotateValue + event.angle;
                }
              })
              // When fingers lift, fix the component at the final rotation angle.
              .onActionEnd(() => {
                this.rotateValue = this.angle
                console.info('RotationGesture is onActionEnd')
              })
              .onActionCancel(() => {
                console.info('RotationGesture is onActionCancel')
              }),
            PinchGesture({ fingers: 2 })
              .onActionStart((event: GestureEvent | undefined) => {
                console.info('Pinch start');
              })
              .onActionUpdate((event: GestureEvent | undefined) => {
                if (event) {
                  this.scaleValue = this.pinchValue * event.scale;
                  this.pinchX = event.pinchCenterX
                  this.pinchY = event.pinchCenterY
                }
              })
              .onActionEnd(() => {
                this.pinchValue = this.scaleValue
                console.info('Pinch end');
              })
          )
        )

        Column({ space: 10 }) {
          ArcButton({ options: this.backOptions })
          Text(`angle: ${this.angle.toFixed(2)}\nscale: ${this.scaleValue.toFixed(2)}`)
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