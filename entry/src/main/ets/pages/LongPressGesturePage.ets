/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-single-gesture
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function LongPressGesturePageBuilder() {
  LongPressGesturePage();
}

@Component
export struct LongPressGesturePage {
  @Consume pathStack: NavPathStack;
  @State private count: number = 0;
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
        Column({ space: 12 }) {
          Text(this.count === 0 ? 'Press long' : 'LongPress OnAction:')
          Text(this.count === 0 ? '' : this.count.toString())
        }
        .gesture(
          // Bind a long press gesture that can be triggered repeatedly.
          LongPressGesture({ repeat: true })
            .onAction((event: GestureEvent | undefined) => {
              if (event) {
                if (event.repeat) {
                  this.count++;
                }
              }
            })
            .onActionEnd(() => {
              this.count = 0;
            })
        )
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        Column() {
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