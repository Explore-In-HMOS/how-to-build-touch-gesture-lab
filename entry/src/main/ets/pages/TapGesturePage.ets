/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-gesture-events-single-gesture
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function TapGesturePageBuilder() {
  TapGesturePage();
}

@Component
export struct TapGesturePage {
  @Consume pathStack: NavPathStack;
  @State private value: string = '';
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
          Text('Click twice').fontSize(28)
          Text(this.value)
        }
        .gesture(
          // Bind a tap gesture with count set to 2 (double-tap).
          // You can set to 1 for single tap
          TapGesture({ count: 2 })
            .onAction((event: GestureEvent | undefined) => {
              if (event) {
                let val = `Double tapped!\n`
                val += `id: ${event.fingerList[0].id}, display: (${event.fingerList[0].displayX.toFixed(2)}, ${event.fingerList[0].displayY.toFixed(2)})`
                this.value = val;
              }
            }))
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