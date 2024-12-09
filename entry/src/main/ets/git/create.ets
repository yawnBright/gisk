import {url_create_repo, url_list_repos, gitee_default_path } from '../config/gitee'
import { FileNodeData } from '../pages/component/filenode'
import { BusinessError } from '@kit.BasicServicesKit';
import { stream, util  } from '@kit.ArkTS';

import { session } from '../utils/request'


interface DataToCreateRepo {
  access_token: string, // 用户授权码
  name: string,         // 仓库名称
  description: string,  // 仓库描述
  has_issues: boolean,  // 是否允许提issue
  has_wiki: boolean     // 是否提供wiki
  can_comment: boolean  // 是否运行comment
}

// 创建仓库
export async function createRepo(name: string, description: string, key: string) {
  let data: DataToCreateRepo = {
    access_token: key,
    name: name,
    description: description,
    has_issues: false,
    has_wiki: false,
    can_comment: false,
  }
  try {
    let response = await session.post(url_create_repo, data)

  } catch (e) {
    console.error('gisk err: ' + JSON.stringify(e))
  }
}


// 新建文件
interface DataToAddBlankFile {
  access_token: string, // 用户授权码
  content: string
  message: string
}
// 'https://gitee.com/api/v5/repos/{owner}/{repo}/contents/{path}
export async function addBlankFile(owner: string, repo: string, path: string, key: string) {
  let url = gitee_default_path +
    '/' + owner +
    '/' + repo +
    '/contents' +
    '/' + path
  let data: DataToAddBlankFile = {
    access_token: key,
    content: '',
    message: 'new_file_from_gisk'
  }
  try {
    let response = await session.post(url, data)
    let res_json = response.toJSON()
    if(res_json) {
      return res_json['content']['sha'] as string
    } else {
      return ''
    }
  } catch (err) {
    return ''
  }
}

export async function addTextFile(owner: string, repo: string, path: string, content: string, key: string) {
  let url = gitee_default_path +
    '/' + owner +
    '/' + repo +
    '/contents' +
    '/' + path

  let base64helper = new util.Base64Helper()
  let textEncoder = new util.TextEncoder("utf-8")
  let array: Uint8Array = textEncoder.encodeInto(content)
  let cont = base64helper.encodeToStringSync(array)

  let data: DataToAddBlankFile = {
    access_token: key,
    content: cont,
    message: 'new_file_from_gisk'
  }
  try {
    let response = await session.post(url, data)
    let res_json = response.toJSON()
    if(res_json) {
      return res_json['content']['sha'] as string
    } else {
      return ''
    }
  } catch (err) {
    return ''
  }
}

