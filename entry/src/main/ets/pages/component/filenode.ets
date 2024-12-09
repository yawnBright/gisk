export interface FileNodeData {
  repo: string
  name: string,
  type: string,  // 文件或文件夹
  path: string,
  sha: string,   //文件的 Blob SHA
}


@Component
export struct FileNode {
  @State file_node: FileNodeData = {
    repo: '',
    name: '测试',
    type: 'dir',
    path: '/',
    sha: '',
  }

  build() {
    Column() {
      Row() {
        Image(this.get_file_icon(this.file_node.type, this.file_node.name))
          .height(40)
          .width(40)
          .draggable(false)
      }
      Row() {
        Text(this.file_node.name)
          .maxLines(2)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
    }
    .justifyContent(FlexAlign.Center)
  }

  get_file_icon(type: string, name: string) {
    if(type === 'dir') {
      return $r('app.media.dir')
    }
    let suffix = ''
    let idx = name.indexOf('.')
    suffix = name.substring(idx + 1)
    switch (suffix) {
      case 'txt': return $r('app.media.txt')
      case 'py': return $r('app.media.python')
      default :return $r('app.media.txt')
    }
  }
}