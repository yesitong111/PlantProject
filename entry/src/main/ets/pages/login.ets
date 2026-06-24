import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct LoginPage {
  @State userName: string = ""
  @State pwd: string = ""
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    preferences.getPreferences(getContext(this), "userData")
      .then(res => this.prefDB = res)
  }

  submitLogin() {
    if(this.userName == "" || this.pwd == ""){
      promptAction.showToast({message: "账号密码不能为空！"})
      return
    }
    this.prefDB?.putSync("user", this.userName)
    promptAction.showToast({message: "登录成功"})
    router.back()
  }

  build() {
    Column({space: 20}) {
      Text("用户登录")
        .fontSize(28)
        .margin({bottom: 20})
      TextInput({text: this.userName, placeholder: "输入用户名/学号"})
        .width("90%")
        .height(50)
        .onChange(val => this.userName = val)
      TextInput({text: this.pwd, placeholder: "输入密码"})
        .width("90%")
        .height(50)
        .type(InputType.Password)
        .onChange(val => this.pwd = val)
      Button("确认登录")
        .width("80%")
        .height(55)
        .margin({top: 20})
        .onClick(()=> this.submitLogin())
    }
    .width("100%")
    .height("100%")
    .padding(15)
  }
}