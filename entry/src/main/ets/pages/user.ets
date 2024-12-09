import { newUser } from '../utils/user'


@Component
export struct User {
  @State uname: string = ''
  @State passwd: string = ''
  @Link show_login: boolean
  @Link owner: string

  onLogin: () => void = () => {}
  build() {
    Stack() {
      if(this.show_login) {
        // 登录页面
        Column() {
          Row() {
            TextInput({placeholder: '用户名'})
              .width('80%')
              .onChange((val) => {
                this.uname = val
              })
              .onPaste((val) => {
                this.uname = this.uname + val
              })
          }
          Row() {
            TextInput({placeholder: '密码'})
              .width('80%')
              .type(InputType.Password)
              .onChange((val) => {
                this.passwd = val
              })
              .onPaste((val) => {
                this.passwd = this.passwd + val
              })
          }
          .margin({top: 20})

          Button('登录')
            .width('35%')
            .margin({top: 15})
            .onClick(async () => {
              // 先简单地检查一下
              if(this.uname != '' && this.passwd != '') {
                let res = await newUser(this.uname, this.passwd)
                // 登录？注册成功
                if(res) {
                  //console.error('登录成功')
                  // 清除焦点 收起键盘
                  this.getUIContext().getFocusController().clearFocus()
                  this.owner = this.uname.toLowerCase()
                  this.onLogin()
                  this.show_login = false
                }
                // 失败
                else {
                  console.error('登录失败')
                }
              }
            })

          // for test
          Text('553f923e432a48b9f70d9eae6566c341')
            .copyOption(CopyOptions.InApp)
        }
        .justifyContent(FlexAlign.Center)
      }
      // 显示登录后
      else {
        Column() {
          Row() {
            // 头像
            Row() {
              Image($r('app.media.user_s'))
                .height(80)
                .width(80)
            }
            // 昵称
            Row() {
              Text('yawnBright')
            }
          }
        }
      }
    }

  }
}