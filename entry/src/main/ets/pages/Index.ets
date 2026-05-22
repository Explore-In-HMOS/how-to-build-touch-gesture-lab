import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from '@ohos.arkui.ArcList'
import { ComponentContent } from '@kit.ArkUI';

interface PageButtonInfo {
  pageName: string;
  buttonText: string;
}

@Builder
function header(title: string) {
  Text(title)
    .fontColor(Color.White)
    .fontSize(16)
    .margin({ top: 20 })
}

@Entry
@Component
struct Index {
  private readonly title: string = 'Touch Gesture Lab'
  @Provide pathStack: NavPathStack = new NavPathStack()
  private readonly buttonInfos: PageButtonInfo[] = [
    { pageName: 'MultiTouchPage', buttonText: 'Multi-touch' },
    { pageName: 'TapGesturePage', buttonText: 'Tap Gesture' },
    { pageName: 'LongPressGesturePage', buttonText: 'Long Press Gesture' },
    { pageName: 'PanGesturePage', buttonText: 'Pan Gesture' },
    { pageName: 'PinchGesturePage', buttonText: 'Pinch Gesture' },
    { pageName: 'RotationGesturePage', buttonText: 'Rotation Gesture' },
    { pageName: 'SwipeGesturePage', buttonText: 'Swipe Gesture' },
    { pageName: 'SequentialCombinedGesturePage', buttonText: 'Sequential gesture' },
    { pageName: 'ParallelCombinedGesturePage', buttonText: 'Parallel gesture' },
    { pageName: 'CustomGesturePage', buttonText: 'Custom gesture' }
  ]
  context: UIContext = this.getUIContext();
  arcListHeader: ComponentContent<string> = new ComponentContent(
    this.context,
    wrapBuilder<[string]>(header),
    this.title
  );

  build() {
    Navigation(this.pathStack) {
      Column({ space: 10 }) {
        ArcList({ header: this.arcListHeader }) {
          ForEach(this.buttonInfos, (info: PageButtonInfo) => {
            ArcListItem() {
              Row() {
                Text(info.buttonText)
              }
              .justifyContent(FlexAlign.Center)
              .height(50)
              .width('100%')
              .borderRadius(25)
              .backgroundColor('#26FFFFFF')
              .onClick(() => {
                this.pathStack.pushPathByName(info.pageName, null)
              })
            }
            .margin({ right: 15, left: 15, bottom: 5 }
            )
          }, (info: PageButtonInfo) => info.pageName)

        }
        .focusable(true)
        .defaultFocus(true)
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
  }
}