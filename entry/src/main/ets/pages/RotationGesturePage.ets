/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-single-gesture
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function RotationGesturePageBuilder() {
  RotationGesturePage();
}

@Component
export struct RotationGesturePage {
  @Consume pathStack: NavPathStack;
  @State angle: number = 0;
  @State eventAngle: number = 0;
  @State rotateValue: number = 0;
  @State isRotating: boolean = false;
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
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .gesture(
          RotationGesture()
            .onActionStart((event: GestureEvent | undefined) => {
              console.info('RotationGesture is onActionStart')
            })
            // When the rotation gesture is triggered, obtain the rotation angle and apply it to the component.
            .onActionUpdate((event: GestureEvent | undefined) => {
              if (event) {
                this.isRotating = true
                this.eventAngle = event.angle;
                this.angle = this.rotateValue + event.angle;
              }
            })
            // When fingers lift, fix the component at the final rotation angle.
            .onActionEnd(() => {
              this.rotateValue = this.angle
              this.isRotating = false
              console.info('RotationGesture is onActionEnd')
            })
            .onActionCancel(() => {
              console.info('RotationGesture is onActionCancel')
            })
        )

        Column({ space: 10 }) {
          ArcButton({ options: this.backOptions })
          Text(this.isRotating ? `event angle: ${this.eventAngle.toFixed(2)}` : 'No rotation')
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