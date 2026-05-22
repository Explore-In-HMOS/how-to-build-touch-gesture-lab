/*
 * reference: https://developer.huawei.com/consumer/en/doc/harmonyos-references/ts-gesture-customize-judge#example-3-implementing-real-time-monitoring-of-active-touch-points-in-gestures
 */
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Builder
export function CustomGesturePageBuilder() {
  CustomGesturePage();
}

@Component
export struct CustomGesturePage {
  @Consume pathStack: NavPathStack;
  @State message: string = 'Touch area'
  @State fingerCount: number = 0
  @State fingerDetails: string = ''
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
          Column() {
            Text(this.message)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)

            Text(`Active touch points: ${this.fingerCount}`)
              .fontSize(16)
              .margin({ top: 8 })


            Text(this.fingerDetails)
              .fontSize(14)
              .margin({ top: 8 })
          }
          .padding(10)
          .border({ width: 1, color: Color.Gray })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            TapGesture()
              .onAction(() => {
                this.message = 'Tap event'
              }),
            LongPressGesture()
              .onAction(() => {
                this.message = 'Long press event'
              }),
            PanGesture()
              .onActionStart(() => {
                this.message = 'Drag started'
              })
              .onActionUpdate(() => {
                this.message = 'Dragging...'
              })
              .onActionEnd(() => {
                this.message = 'Drag ended'
                this.fingerCount = 0
                this.fingerDetails = ''
              })
          )
        )
        .onGestureJudgeBegin((gestureInfo: GestureInfo, event: BaseGestureEvent) => {
          // Access fingerInfos data.
          if (event?.fingerInfos) {
            this.fingerCount = event.fingerInfos.length
            this.fingerDetails = event.fingerInfos.map(finger =>
            `ID: ${finger.id}: (${finger.localX.toFixed(1)}, ${finger.localY.toFixed(1)})`
            ).join('\n')
            console.info(`Touch point data: ${JSON.stringify(event.fingerInfos)}`)
          }
          if (this.fingerCount > 2) {
            return GestureJudgeResult.REJECT
          }
          return GestureJudgeResult.CONTINUE
        })

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