// import { getTextFileByPath, searchRepoByName, listContByPath } from '../git/search'
// import { createRepo, addBlankFile, addTextFile } from '../git/create'
// import { root_repo } from '../config/gitee'
// import { Db } from '../utils/kvdb'
// interface FileNodeData {
//   path: string,
//   type: string,
//   child: Array<FileNodeData>
// }
//
// export async function initFileSystem(owner: string, key: string) {
//   // 从远程仓库读取根仓库
//   let res = await searchRepoByName(owner, root_repo, key)
//   // 如果根仓库存在
//   if(res) {
//     // 读取根文件
//     let root_file_str = await getTextFileByPath(owner, root_repo, 'root_file.txt', key)
//     let root_file_node_data = JSON.parse(root_file_str) as FileNodeData
//     // 获取根文件sha
//     let tmp = await listContByPath(owner, root_repo, '/', key)
//     await Db.kvStore?.put('root_file_sha', tmp[0].sha)
//   }
//   // 根仓库不存在
//   else {
//     // 创建根仓库
//     await createRepo(root_repo, 'gisk file system config file', key)
//     // 添加根文件
//     let init_root_file: FileNodeData = {
//       path: '/',
//       type: 'dir',
//       child: []
//     }
//     let sha = await addTextFile(owner, root_repo, 'root_file.txt', JSON.stringify(init_root_file), key)
//     //let sha = await addBlankFile(owner, root_repo, 'root_file.txt')
//     while(sha === '') {
//       sha = await addBlankFile(owner, root_repo, 'root_file.txt', key)
//     }
//     // 将sha
//     await Db.kvStore?.put('root_file_sha', sha)
//   }
//
//
//   // 从根仓库的根文件读取数据并构建文件系统
//
//   //
// }