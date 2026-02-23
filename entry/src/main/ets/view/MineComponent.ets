@Component
export struct MineComponent {
  scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        // Mock Content
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], (item: number) => {
          Row() {
            Text(`我的页面内容 ${item}`)
              .fontSize(20)
              .fontColor(Color.Black)
          }
          .width('90%')
          .height(80)
          .backgroundColor('#E6F7FF')
          .borderRadius(10)
          .margin({ bottom: 10 })
          .justifyContent(FlexAlign.Center)
        })
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
  }
}
