// import { createRepo } from '../../utils/git'
import { createRepo } from '../../git/create'

@CustomDialog
export struct FileDialog {
  @State is_show_new_dir: boolean = false
  @Link passwd: string
  confirm?: () => void
  controller: CustomDialogController = new CustomDialogController({
    builder: FileDialog({
      passwd: this.passwd
    }),
  })

  build() {
    Column() {
      Row() {
        FileOperationNode({icon: $r('app.media.new_dir'), description: '新建文件夹'})
          .onClick(() => {
            this.is_show_new_dir = true
          })
        FileOperationNode({icon: $r('app.media.new_file'), description: '上传文件'})
          .onClick(() => {

          })
        FileOperationNode({icon: $r('app.media.add_img'), description: '上传图片'})
          .onClick(() => {

          })

      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .height('30%')
      .margin({top: 15})

      if(this.is_show_new_dir) {
        Row() {
          NewDir({is_show: this.is_show_new_dir, passwd: this.passwd})
            .height('50%')
            .width('80%')

        }
        //.backgroundColor('#ff59cac6')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .width('100%')
        .height('70%')
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#d5f8f8f8')
  }
}



@Component
struct FileOperationNode {
  icon: Resource = $r('app.media.new_dir')
  description: string = ''
  build() {
    Column() {
      Image(this.icon)
        .height(40)
        .width(40)
      Text(this.description)
        .margin({top: 5})
        .fontSize(12)
    }
    .height(75)
    .width(75)
    .borderRadius('12%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#eeffffff')
  }
}

@Component
struct NewDir {
  @State dir_name: string = ''
  @Link is_show: boolean
  @Link passwd: string

  build() {
    Column() {
      Text('添加文件夹')
        .margin({bottom: '5%', top: '1%'})

      TextInput({placeholder: '文件夹名称'})
        .width('90%')
        .onChange((val) => {
          this.dir_name = val
        })
        .onPaste((val) => {
          this.dir_name += val
        })
      Row() {
        Button('取消')
          .width('40%')
          .onClick(() => {
            this.is_show = false
          })
        Button('确认')
          .width('40%')
          .onClick(async () => {
            // 这里进行简单判断
            if(this.dir_name != '') {
              // 获取时间戳，创建唯一仓库名称
              let time_stamp = Date.now()
              let random_repo_name: string = 'file' + time_stamp.toString()
              await createRepo(random_repo_name, this.dir_name, this.passwd)
            }
            this.is_show = false
          })
      }
      .width('90%')
      .margin({top: '40%'})
      .justifyContent(FlexAlign.SpaceAround)

    }
    .backgroundColor('#e1bdeae9')
    .height('100%')
    .width('100%')
    .borderRadius('14%')
  }
}