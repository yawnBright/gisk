import { Db } from '../utils/kvdb'
import { checkLogin } from '../utils/user'
import { Home } from './home'
import { User } from './user'
import { FileSystem } from '../fileSystem/filesystemAPI'
//import { initFileSystem } from '../fileSystem/initFileSystem'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State show_login: boolean = false
  @State update_home_page_data_flag: boolean = false
  @State owner: string = ''
  @State passwd: string = ''


  async aboutToAppear(): Promise<void> {
    // 初始化数据库
    await Db.init()
    // 检查用户登录状态
    let status = await checkLogin()
    // 如果已经登录
    // -----------------------
    if(status.status === 0) {
      // 更新用户名和密钥
      this.owner = status.uname.toLowerCase()
      this.passwd = status.passwd
      // 更新主页数据
      this.update_home_page_data_flag = !this.update_home_page_data_flag
      // 加载文件系统
      let giskFS = new FileSystem(this.owner, this.passwd)
      await giskFS.init()
      //giskFS.newDirectory('/the_4_test')
      //let fsData = await initFileSystem(this.owner, this.passwd)
      //console.error(JSON.stringify(fsData))
    }
    // 未登录
    // ------------------------
    else {
      this.show_login = true
      // 跳转到用户页
      this.currentIndex = 1
    }
  }
  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        Home({
          update_flag: this.update_home_page_data_flag,
          owner: this.owner,
          passwd: this.passwd
        })
          .height('100%')
          .width('100%')
      }
      .tabBar(this.tabBuilder('首页', 0, $r('app.media.home_s'), $r('app.media.home')))

      TabContent() {
        // Column() {
        //   Text(this.show_login ? '未登录' : '已登陆')
        //     .fontSize(100)
        // }
        // .backgroundColor('#007DFF')
        User({
          show_login: this.show_login,
          owner: this.owner,
          onLogin: () => {
            // 登录成功后切回主页
            this.currentIndex = 0
            // 更新云盘数据
            this.update_home_page_data_flag = !this.update_home_page_data_flag
            //this.update_net_disk_data()



          }
        })
          .height('100%')
          .width('100%')
      }
      .tabBar(this.tabBuilder('我的', 1, $r('app.media.user_s'), $r('app.media.user')))
    }
    .scrollable(false)
    .animationDuration(0)
    .onChange((index: number) => {
      this.currentIndex = index
    })
    // Button('新建文件夹')
    //   .onClick(async () => {
    //     await create('鸿蒙云盘测试')
    //   })
  }


  @Builder tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 25, height: 25 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  // update_net_disk_data() {
  //
  // }
}