import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { HomeComponent } from '../view/HomeComponent';
import { MineComponent } from '../view/MineComponent';
import curves from '@ohos.curves';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();
  // Scrollers for child components to support scroll-to-top
  private homeScroller: Scroller = new Scroller();
  private mineScroller: Scroller = new Scroller();

  // Scale states for tab bounce animation
  @State tabScales: number[] = [1.0, 1.0];

  @State title: string = "首页";
  @State topRectHeight: number = 0;
  @State bottomRectHeight: number = 0;

  async aboutToAppear() {
    try {
      let windowClass = await window.getLastWindow(getContext(this));
      
      // Get Top Status Bar Height
      let typeSystem = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidAreaSystem = windowClass.getWindowAvoidArea(typeSystem);
      this.topRectHeight = px2vp(avoidAreaSystem.topRect.height);

      // Get Bottom Navigation Indicator Height
      let typeNav = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      let avoidAreaNav = windowClass.getWindowAvoidArea(typeNav);
      this.bottomRectHeight = px2vp(avoidAreaNav.bottomRect.height);
      
      // Update if screen rotates or changes
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topRectHeight = px2vp(data.area.topRect.height);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.bottomRectHeight = px2vp(data.area.bottomRect.height);
        }
      });
    } catch (exception) {
      console.error('Failed to obtain the window. Cause: ' + JSON.stringify(exception));
    }
  }

  @Builder
  TabBuilder(index: number, title: string, normalIcon: Resource, selectedIcon: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedIcon : normalIcon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        // Apply scale for bounce effect
        .scale({ x: this.tabScales[index], y: this.tabScales[index] })
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#182431')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: this.bottomRectHeight }) // Pad bottom for safe area
    .onClick(() => {
      // Trigger Bounce Animation
      this.triggerBounce(index);

      if (this.currentIndex === index) {
        // Current tab clicked: Scroll to top
        if (index === 0) {
          this.homeScroller.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: 300 } });
        } else if (index === 1) {
          this.mineScroller.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: 300 } });
        }
      } else {
        // Switch tab
        this.currentIndex = index;
        this.controller.changeIndex(index);
      }
    })
  }

  // Custom bounce animation specifically for Image components
  triggerBounce(index: number) {
    // 1. Scale down rapidly
    animateTo({ duration: 50, curve: Curve.EaseOut }, () => {
      this.tabScales[index] = 0.9;
    });

    // 2. Scale back up with a spring effect after a slight delay
    setTimeout(() => {
      animateTo({ duration: 300, curve: curves.springMotion(0.6, 0.7) }, () => {
        this.tabScales[index] = 1.0;
      });
    }, 60);
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Top }) {
        // Content Area
        Column() {
          Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
            TabContent() {
              HomeComponent({ scroller: this.homeScroller })
            }
            .tabBar(this.TabBuilder(
              0, 
              '首页', 
              $r('app.media.house_fill'), 
              $r('app.media.house_fill_active')
            ))

            TabContent() {
              MineComponent({ scroller: this.mineScroller })
            }
            .tabBar(this.TabBuilder(
              1, 
              '我的', 
              $r('app.media.folder_fill'), 
              $r('app.media.folder_fill_active')
            ))
          }
          .scrollable(false) // Disable swipe to rely on tap interactions
          .animationDuration(300)
          .barOverlap(true) // Overlay tab bar on content
          .barBackgroundColor('#00000000') // Transparent background to allow blur to show
          .barBackgroundBlurStyle(BlurStyle.Thick) // Apply blur effect
          .barHeight(56 + this.bottomRectHeight) // Extend bar height to include safe area
          .onChange((index: number) => {
            this.currentIndex = index;
            this.title = index === 0 ? "首页" : "我的";
          })
        }
        .width('100%')
        .height('100%')
        // Add padding to content bottom so it's not hidden behind the overlapped tab bar
        .padding({ bottom: 1  }) // Small bottom padding, major spacing handled by list/scroll content usually
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]) // Allow content including map/list to go behind status/nav bar

        // Custom Blurred Title Bar
        Row() {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
        }
        .width('100%')
        .height(56 + this.topRectHeight) // Height includes status bar
        .padding({ left: 16, top: this.topRectHeight }) // Pad top to avoid status bar overlap
        .backgroundColor('#00000000') // Transparent
        .backgroundBlurStyle(BlurStyle.Thick) // Apply blur effect
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true) // Hide system title bar to use our custom blurred one
    .hideBackButton(true)
    .backgroundColor('#F1F3F5') // Light gray background for the whole app
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]) // Make navigation full screen
  }
}
