import { initFileSystem } from './init'
import { createRepo } from '../git/create'
import { modifyFile } from '../git/modify'
import { root_repo } from '../config/gitee'
import { Db } from '../utils/kvdb'


export interface FileNodeData {
  path: string,
  name: string,
  type: string,
  repo: string,
  child: Array<FileNodeData>,
}

// enum FileSystemErr {
//
// }

export class FileSystem {
  private fsData: FileNodeData = {
    path: '/',
    name: '/',
    type: 'dir',
    repo: '',
    child: []
  }
  private owner: string = ''
  private key: string = ''
  private root_file_sha: string = ''

  constructor(owner: string, key: string) {
    this.owner = owner
    this.key = key
  }

  async init() {
    this.fsData = await initFileSystem(this.owner, this.key)
    this.root_file_sha = await Db.kvStore?.get('root_file_sha') as string
  }

  private findBelowFileNode(trace: Array<number>, name: string, type: string) {
    //let res = -1
    if(trace.length === 0) {
      // 在根目录下寻找
      for(let i= 0; i < this.fsData.child.length; ++i) {
        // 找到目标节点
        if(this.fsData.child[i].name === name && this.fsData.child[i].type === type) {
          return i
        }
      }
      // 找不到目标节点
      return -1
    }
    else {
      let end_node: FileNodeData = this.fsData
      trace.map((node_id) => {
        // 这里先不考虑下标越界的情况
        end_node = end_node.child[node_id]
      })
      for(let i= 0; i < end_node.child.length; ++i) {
        // 找到目标节点
        if(end_node.child[i].name === name && end_node.child[i].type === type) {
          return i
        }
      }
      return -1
    }
  }

  private addBelowFileNode(trace: Array<number>, new_node: FileNodeData) {
    if(trace.length === 0) {
      this.fsData.child.push(new_node)
    } else {
        let end_node: FileNodeData = this.fsData
        trace.map((node_id) => {
          // 这里先不考虑下标越界的情况
          end_node = end_node.child[node_id]
        })
        end_node.child.push(new_node)
    }
  }


  // 暂不支持自动创建不存在的文件夹
  async newDirectory(path: string) {
    let res = 0
    if(path === '')
      return -1
    try {
      let path_arr = path.split('/')   // ["","path","dir1","dir2","file1.txt"]
      let trace: Array<number> = []

      for(let i = 0; i < path_arr.length; ++i) {
        if(i === 0) {
          // 根路径不是 /    这里先不区分错误类型
          if(path_arr[i] !== '') {
            res = -1
            break
          }
        } else {
          // 路径中出现连续的 /
          if(path_arr[i] === '') {
            res = -1
            break
          }
          let node_idx = this.findBelowFileNode(trace, path_arr[i], 'dir')
          // 如果存在这个节点
          if(node_idx != -1) {
            // 待创建的文件夹已经存在
            if(i === path_arr.length - 1) {
              res = 0
              break
            }
            // 还需深入文件树
            else {
              trace.push(node_idx)
            }
          }
          // 不存在这个节点
          else {
            // 已经是最后一个了，则创建该文件夹
            if(i === path_arr.length - 1) {
              // 获取时间戳，创建唯一仓库名称
              let time_stamp = Date.now()
              let repo_name: string = 'file' + time_stamp.toString()
              let new_dir: FileNodeData = {
                type: 'dir',
                path: path,
                name: path_arr[i],
                repo: repo_name,
                child: []
              }
              // 本地修改
              this.addBelowFileNode(trace, new_dir)
              // 创建远程仓库
              await createRepo(repo_name, 'create_by_gisk', this.key)
              // 远端同步根文件
              await this.saveToNet()
              res = 0
            }
            // 路径的中间节点不存在，可能是路径有误
            else {
              res = -1
              break
            }
          }
        }
      }
      return res
    } catch (err) {
      return -1
    }
  }

  async newFile() {

  }

  async deleteDirectory() {

  }

  async deleteFile() {

  }

  async saveToNet() {
    let root_file_data = JSON.stringify(this.fsData)
    console.error(root_file_data)
    await modifyFile(this.owner, root_repo, 'root_file.txt', this.root_file_sha, root_file_data, this.key)
  }

}