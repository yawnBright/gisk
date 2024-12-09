import { gitee_default_path } from '../config/gitee'
import { session } from '../utils/request'


// 删除仓库
export async function deleteRepo(owner: string, repo: string, key: string) {
  try {
    let url = gitee_default_path + '/' + owner + '/' + repo + '?access_token=' + key
    await session.delete(url)
    return true
  } catch (err) {
    console.error('删除仓库失败：' + err)
    return false
  }
}

// 删除仓库中指定文件
export async function deleteFileInRepo(owner: string, repo: string, path: string, sha: string, key: string) {
  try {
    let url = gitee_default_path +
      '/' + owner +
      '/' + repo +
      '/contents' +
      '/' + path +
      '?sha=' + sha +
      '&access_token=' + key +
      '&message=delete_from_gisk'
    await session.delete(url)
    return true
  } catch (err) {
    console.error('删除仓库文件失败：' + err)
    return false
  }

}