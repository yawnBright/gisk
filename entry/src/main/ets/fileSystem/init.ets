import { getTextFileByPath, searchRepoByName, listContByPath } from '../git/search'
import { createRepo, addBlankFile, addTextFile } from '../git/create'
import { root_repo } from '../config/gitee'
import { Db } from '../utils/kvdb'
import { FileNodeData } from './filesystemAPI'


export async function initFileSystem(owner: string, key: string) {
  // 从远程仓库读取根仓库
  let res = await searchRepoByName(owner, root_repo, key)
  // 如果根仓库存在
  if(res) {
    // 获取根文件sha
    let tmp = await listContByPath(owner, root_repo, '/', key)
    await Db.kvStore?.put('root_file_sha', tmp[0].sha)

    // 读取根文件
    let root_file_str = await getTextFileByPath(owner, root_repo, 'root_file.txt', key)
    let fsData = JSON.parse(root_file_str) as FileNodeData

    return fsData
  }
  // 根仓库不存在
  else {
    // 创建根仓库
    await createRepo(root_repo, 'gisk file system config file', key)
    // 添加根文件
    let init_fs_data: FileNodeData = {
      path: '/',
      name: '/',
      type: 'dir',
      repo: root_repo,
      child: []
    }
    let sha = await addTextFile(owner, root_repo, 'root_file.txt', JSON.stringify(init_fs_data), key)
    //let sha = await addBlankFile(owner, root_repo, 'root_file.txt')
    while(sha === '') {
      sha = await addBlankFile(owner, root_repo, 'root_file.txt', key)
    }
    // 将sha
    await Db.kvStore?.put('root_file_sha', sha)

    return init_fs_data
  }


  // 从根仓库的根文件读取数据并构建文件系统

  //
}