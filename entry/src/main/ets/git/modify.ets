import { url_create_repo, url_list_repos, gitee_default_path } from '../config/gitee'
import { FileNodeData } from '../pages/component/filenode'
import { BusinessError } from '@kit.BasicServicesKit';
import { stream, util  } from '@kit.ArkTS';

import { session } from '../utils/request'


// 'https://gitee.com/api/v5/repos/{owner}/{repo}/contents/{path}
// 目前只能修改文本文件 可能是这样
interface DataToModifyFile {
  content: string,
  sha: string,
  message: string,
  access_token: string,
}
export async function modifyFile(owner: string, repo: string, path: string, sha: string, content: string, key: string) {
  let url = gitee_default_path +
    '/' + owner +
    '/' + repo +
    '/contents' +
    '/' + path
  let base64helper = new util.Base64Helper()
  let textEncoder = new util.TextEncoder("utf-8")
  let array: Uint8Array = textEncoder.encodeInto(content)
  let cont = base64helper.encodeToStringSync(array)

  let data: DataToModifyFile = {
    content: cont,
    sha: sha,
    message: 'modify_by_gisk',
    access_token: key
  }

  await session.put(url, data)
  //return array

  //base64helper.encodeToStringSync()
}