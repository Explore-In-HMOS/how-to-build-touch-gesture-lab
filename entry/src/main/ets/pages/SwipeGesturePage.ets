/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-single-gesture
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function SwipeGesturePageBuilder() {
  SwipeGesturePage();
}

@Component
export struct SwipeGesturePage {
  @Consume pathStack: NavPathStack;
  @State rotateAngle: number | undefined = undefined;
  @State speed: number = 1;
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
          Text(this.rotateAngle === undefined ? 'Swipe in the vertical direction' :
            `angle: ${this.rotateAngle.toFixed(2)}\nSwiped ${this.rotateAngle < 0 ? 'up' : 'down'}`)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .gesture(
          // Bind a swipe gesture that triggers only for vertical swipes.
          SwipeGesture({ direction: SwipeDirection.Vertical })
          // When the swipe gesture is triggered, obtain the swipe speed and angle to modify layout parameters.
            .onAction((event: GestureEvent | undefined) => {
              if (event) {
                this.speed = event.speed;
                this.rotateAngle = event.angle;
              }
            })
        )

        Column({ space: 10 }) {
          ArcButton({ options: this.backOptions })
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