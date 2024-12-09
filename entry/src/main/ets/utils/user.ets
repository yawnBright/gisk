import { Db } from './kvdb'

interface LoginStatus {
  uname: string,
  passwd: string,
  status: number,  // -1 没有用户信息 0 用户信息正确 1 用户信息正确且保持登录
}


export async function checkLogin() {
  let res: LoginStatus = {
    uname: '',
    passwd: '',
    status: -1
  }
  try {
    let uname: string = await Db.kvStore?.get('username') as string
    let passwd: string = await Db.kvStore?.get('passwd') as string
    res.uname = uname
    res.passwd = passwd
    res.status = 0
  } catch (err) {

  }

  return res
}


export async function newUser(uname: string, passwd: string) {
  try {
    await Db.kvStore?.put('username', uname)
    await Db.kvStore?.put('passwd', passwd)
    return true
  } catch (err) {
    return false
  }
}