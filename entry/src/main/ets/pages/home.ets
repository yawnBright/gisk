import { listRepos, listContByPath } from '../git/search'
import { deleteRepo, deleteFileInRepo } from '../git/delete'
import { FileNode, FileNodeData } from './component/filenode'
import { FileDialog } from './component/fileDialog'
//import { initFileSystem } from '../fileSystem/fileNodeData'
import { common } from '@kit.AbilityKit';
@Component
export struct Home {
  @State is_refreshing: boolean = false
  @State files: Array<FileNodeData> = [
    //{repo: '', name: '测试3', type: 'dir', path: '/'}
  ]

  @State path: Array<string> = ['/']
  @Link owner: string
  @Link passwd: string

  @Prop @Watch('update_page_data') update_flag: boolean = false

  file_dialog: CustomDialogController = new CustomDialogController({
    builder: FileDialog({
      passwd: this.passwd
    }),
  })



  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .height(30)
          .width(30)
          .onClick(async () => {
            // 返回
            if(this.path.length > 1) {
              this.path.pop()
              await this.get_back_level()
            }

          })
      }
      .height(35)
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Button('初始化')
          .onClick(async () => {
            //await downLoadTextFile()
            //await initFileSystem(this.owner, this.passwd)


          })
      }

      Refresh({refreshing: $$this.is_refreshing}) {
        Column() {
          Row() {
            Text(this.get_cur_path())
              .margin({left: 8})
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Grid() {
            ForEach(this.files, (node: FileNodeData) => {
              GridItem() {
                FileNode({
                  file_node: {
                    repo: node.repo,
                    name: node.name,
                    type: node.type,
                    path: node.path,
                    sha: node.sha
                  }
                })
                  .height(80)
                  .width(80)
                    //.backgroundColor(Color.Red)
                  .onClick(async () => {
                    this.onClickFileNode(node)
                  })
                .gesture(
                  LongPressGesture()
                    .onAction((event: GestureEvent|undefined) => {
                      if(event){
                        this.onLongTapFileNode(node.repo, node.path, node.sha, node.type)
                      }
                    })
                    .onActionEnd(() => {
                      //console.error('长按结束')
                    })
                )
              }
              .margin(5)
              //.backgroundColor(Color.Blue)
              // .gesture(
              //   LongPressGesture()
              //     .onAction((event: GestureEvent|undefined) => {
              //       if(event){
              //         console.error('长按开始')
              //       }
              //     })
              //     .onActionEnd(() => {
              //       console.error('长按结束')
              //     })
              // )
            })
          }
          .layoutDirection(GridDirection.Row)
          //.maxCount(10)
        }
      }
      .height('85%')
      //.backgroundColor('#fffcfcfc')
      .onRefreshing(() => {
        this.update_page_data()
      })

      Row() {
        Image($r('app.media.add'))
          .height(53)
          .width(53)
          .margin({right: 10})
          .onClick(() => {
            this.file_dialog.open()
            // 根目录不允许直接创建文件
            if(this.path.length === 1) {

            }
          })
      }
      .height(-1)
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .height('100%')
    .width('100%')

  }

  async update_page_data() {
    let tmp = await listRepos(this.passwd)
    let tmp_files: Array<FileNodeData> = []
    for(let i = 0; i < tmp.length; ++i) {
      let tmp_idx = tmp[i].full_name.indexOf('/')
      let file_node_data: FileNodeData = {
        repo: tmp[i].full_name.substring(tmp_idx + 1),
        name: tmp[i].description,
        type: 'dir',
        path: '/',
        sha: '',
      }
      tmp_files.push(file_node_data)
      //this.files.push(file_node_data)
    }
    this.files = tmp_files
    this.is_refreshing = false
  }
  async get_back_level() {
    // 回到根目录
    if(this.path.length === 1) {
      this.update_page_data()
    }
    // 回到普通目录
    else {
      if(this.path.length === 2) {
        let tmp = await listContByPath(this.owner, this.path[1], '/', this.passwd)
        this.files = tmp
      } else {
        let tmp = await listContByPath(this.owner, this.path[1], this.path[this.path.length - 1], this.passwd)
        this.files = tmp
      }

      //this.files = tmp
    }
  }
  get_cur_path() {
    let res = ''
    let end = this.path.length - 1
    this.path.map((p, idx) => {
      if(idx === 0 || idx === end) {
        res += p
      } else {
        res += p + '/'
      }
    })
    return res
  }
  async onClickFileNode(node: FileNodeData) {
    // 如果是文件夹
    if(node.type === 'dir') {
      let tmp = await listContByPath(this.owner, node.repo, node.path, this.passwd)
      this.files = tmp
      // 在根目录
      if(this.path.length === 1) {
        this.path.push(node.repo)
      } else {
        this.path.push(node.path)
      }
      //this.path.push()
    }
    // 如果是文件
    else {

    }
  }
  onLongTapFileNode(repo: string, path: string, sha: string, type: string) {
    AlertDialog.show({
      title: '删除该文件、文件夹？',
      //subtitle: '',
      message: '',
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      gridCount: 4,
      offset: { dx: 0, dy: -20 },
      primaryButton: {
        value: '取消',
        action: () => {
          //console.info('Callback when the first button is clicked')
        }
      },
      secondaryButton: {
        enabled: true,
        defaultFocus: true,
        style: DialogButtonStyle.HIGHLIGHT,
        value: '确认',
        action: async () => {
          // 在根目录则删除仓库
          if(this.path.length === 1) {
            let res = await deleteRepo(this.owner, repo, this.passwd)
            if(res) {
              // 删除页面该元素
              this.files.map((val, idx) => {
                if(val.repo === repo) {
                  this.files.splice(idx, 1)
                }
              })
            }
          }
          // 否则删除仓库中文件
          else {
            // 目前只能删除文件，还没有api能直接删除文件夹
            if(type === 'file') {
              let res = await deleteFileInRepo(this.owner, repo, path, sha, this.passwd)
              if(res) {
                this.files.map((val, idx) => {
                  if(val.path === path) {
                    this.files.splice(idx, 1)
                  }
                })
              }
            }
          }
        }
      }
    })
    // setTimeout(() => {
    //
    // }, 200)
  }
}