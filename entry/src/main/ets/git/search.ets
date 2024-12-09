import { url_list_repos, gitee_default_path } from '../config/gitee'
import { FileNodeData } from '../pages/component/filenode'
import { session } from '../utils/request'
import { stream, util  } from '@kit.ArkTS';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit';
import { fileIo as fs, ReadOptions, WriteOptions } from '@kit.CoreFileKit';


// 列举所有仓库
interface DataToListRepos {
  access_token: string    // 授权码
  visibility: string      // 仓库可见类型 all(默认值) public private
  // 仓库人员类型 owner(授权用户拥有的仓库)、collaborator(授权用户为仓库成员)
  // 、organization_member(授权用户为仓库所在组织并有访问仓库权限)、
  // enterprise_member(授权用户所在企业并有访问仓库权限)、admin(所有有权限的，
  // 包括所管理的组织中所有仓库、所管理的企业的所有仓库)。 可以用逗号分隔符组合。
  affiliation: string
  page: number            // 当前页
  per_page: number        // 每页的数量，最大为 100
}
interface ListReposResp {
  description: string,
  full_name: string,
}
export async function listRepos(key: string) {
  let res: Array<ListReposResp> = []
  let data: DataToListRepos = {
    access_token: key,
    visibility: 'all',
    affiliation: 'owner',
    page: 1,
    per_page: 20
  }
  let url = url_list_repos
    + '?access_token=' + data.access_token
    + '&visibility=' + data.visibility
    + '&affiliation=' + data.affiliation
    + '&page=' + data.page.toString()
    + '&per_page=' + data.per_page.toString()
  // console.error(url)
  try {
    let response = await session.get(url)
    let res_json = response.toJSON()
    if(res_json) {
      res = res_json as Array<ListReposResp>

      //console.error(repos[0].description)
      //console.error(JSON.stringify(res_json))

    }
  } catch (err) {


  }

  return res
}

// 列举路径下的所有内容
interface ListContResp {
  "type": string,
  "size": number,
  "name": string,
  "path": string,
  "sha": string,
  "url": string,
  "html_url": string,
  "download_url": string,
}
export async function listContByPath(owner: string, repo: string, path: string, key: string) {
  let res: Array<FileNodeData> = []
  let url = gitee_default_path + '/' + owner + '/' + repo + '/contents/' + path + '?access_token=' + key
  try {
    let response = await session.get(url)
    let res_json = response.toJSON() as Array<ListContResp>
    if(res_json) {
      res_json.map((item) => {
        let tmp: FileNodeData = {
          repo: repo,
          type: item.type,
          path: item.path,
          name: item.name,
          sha: item.sha
        }
        res.push(tmp)
      })
    }
  } catch (err) {

  }
  return res
}

// 通过路径获取文本文件字符串内容
export async function getTextFileByPath(owner: string, repo: string, path: string, key: string) {
  let accumulatedData: Uint8Array[] = []; // 用于累积所有下载的数据块
  const streamData: rcp.WriteStream = {
    write(buffer: ArrayBuffer): Promise<void | number> {
      // 将 ArrayBuffer 转换为 Uint8Array 并存储
      const uint8Array = new Uint8Array(buffer);
      accumulatedData.push(uint8Array);
      return Promise.resolve(buffer.byteLength);
    },
  };

  let downloadToStream: rcp.DownloadToStream = {
    kind: 'stream',
    stream: streamData
  };
  const session = rcp.createSession();
  let url = gitee_default_path +
    '/' + owner +
    '/' + repo +
    '/' + 'raw' +
    '/' + path +
    '?access_token=' + key

  let response = await session.downloadToStream(url, downloadToStream)
  // 所有数据块都已接收，现在合并并处理数据
  const combinedArray = new Uint8Array(accumulatedData.reduce((acc, val) => acc + val.length, 0));
  let offset = 0;
  accumulatedData.forEach(chunk => {
    combinedArray.set(chunk, offset);
    offset += chunk.length;
  });
  // 使用 TextDecoder 将合并后的 Uint8Array 转换为字符串
  const textDecoder = new util.TextDecoder();

  const fileContent = textDecoder.decodeToString(combinedArray);
  return fileContent
  //console.error(fileContent); // 打印文件内容
  // 这里可以处理文件内容，例如保存到本地或者进一步处理

}

// 查找特定的仓库
export async function searchRepoByName(owner: string, name: string, key: string) {
  let url = gitee_default_path + '/' + owner + '/' + name + '?access_token=' + key
  try {
    let response = await session.get(url)
    let res_json = response.toJSON()
    if(res_json) {
      if(res_json['message'] === 'Not Found Project') {
        return false
      } else {
        return true
      }
    } else {
      return false
    }
  } catch (err) {
    //
    console.error('搜索仓库发生错误：' + err)
    return false
  }
}



// 获取指定仓库的某个文件
// export async function getFileByPath(owner: string, repo: string, path: string) {
//   let url = url_get_repo_file +
//     '/' + owner +
//     '/' + repo +
//     '/' + path
//   //let buf = buffer.alloc(100) as DownloadToStream
//   //rcp.DownloadToStream
//   //let buf: string = ''
//   let buf = new stream.Writable();
//   //session.downloadToStream(url, buf)
// }




// export async function downLoadTextFile() {
//   let accumulatedData: Uint8Array[] = []; // 用于累积所有下载的数据块
//   const streamData: rcp.WriteStream = {
//     write(buffer: ArrayBuffer): Promise<void | number> {
//       // 将 ArrayBuffer 转换为 Uint8Array 并存储
//       const uint8Array = new Uint8Array(buffer);
//       accumulatedData.push(uint8Array);
//       return Promise.resolve(buffer.byteLength);
//     },
//   };
//
//   let downloadToStream: rcp.DownloadToStream = {
//     kind: 'stream',
//     stream: streamData
//   };
//   const session = rcp.createSession();
//   let response = await session.downloadToStream("https://gitee.com/api/v5/repos/yawnbright/test-for-netdisk/raw/test/file1.txt?access_token=553f923e432a48b9f70d9eae6566c341", downloadToStream)
//   // 所有数据块都已接收，现在合并并处理数据
//   const combinedArray = new Uint8Array(accumulatedData.reduce((acc, val) => acc + val.length, 0));
//   let offset = 0;
//   accumulatedData.forEach(chunk => {
//     combinedArray.set(chunk, offset);
//     offset += chunk.length;
//   });
//   // 使用 TextDecoder 将合并后的 Uint8Array 转换为字符串
//   const textDecoder = new util.TextDecoder();
//
//   const fileContent = textDecoder.decodeToString(combinedArray);
//   console.error(fileContent); // 打印文件内容
//   // 这里可以处理文件内容，例如保存到本地或者进一步处理
// }



// function exam() {
//   let textEncoder = new util.TextEncoder("utf-8");
//   let textDecoder = new util.TextDecoder()
//
//
//   const streamData: rcp.WriteStream = {
//     write(buffer: ArrayBuffer): Promise<void | number> {
//       return Promise.resolve(buffer.byteLength)
//     }
//   };
//
//   let downloadToStream: rcp.DownloadToStream = {
//     kind: 'stream',
//     stream: streamData
//   }
//   const session = rcp.createSession();
//   session.downloadToStream("http://example.com/head", downloadToStream).then((response) => {
//     console.info(`Response succeed: ${response}`);
//   }).catch((err: BusinessError) => {
//     console.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
//   });
//
// }

// export function downloadFile(ctx: common.UIAbilityContext) {
//   let filesDir = ctx.filesDir;
//   let rootFile = fs.openSync(filesDir + '/test.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
//   let my_buf = new ArrayBuffer(4096);
//
//   let str = 'njinsdfijvns'
//
//   let writeOptions: WriteOptions = {
//     length: readLen
//   };
//   fs.writeSync(rootFile.fd, '你好文件系统',)
//
//
//   // 打开文件
//   let srcFile = fs.openSync(filesDir + '/test.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
//   let destFile = fs.openSync(filesDir + '/destFile.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
//   // 读取源文件内容并写入至目的文件
//   let bufSize = 4096;
//   let readSize = 0;
//   let buf = new ArrayBuffer(bufSize);
//   let readOptions: ReadOptions = {
//     offset: readSize,
//     length: bufSize
//   };
//   let readLen = fs.readSync(srcFile.fd, buf, readOptions);
//   while (readLen > 0) {
//     readSize += readLen;
//     let writeOptions: WriteOptions = {
//       length: readLen
//     };
//     fs.writeSync(destFile.fd, buf, writeOptions);
//     readOptions.offset = readSize;
//     readLen = fs.readSync(srcFile.fd, buf, readOptions);
//   }
//   // 关闭文件
//   fs.closeSync(srcFile);
//   fs.closeSync(destFile);
// }