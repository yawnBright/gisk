import { distributedKVStore } from '@kit.ArkData';

class KVDb {
  kvStore: distributedKVStore.SingleKVStore | undefined = undefined
  async init() {
    const context = getContext(this)
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: 'com.example.gisk'
    }
    let kvManager = distributedKVStore.createKVManager(kvManagerConfig)
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: false,
      // kvStoreType不填时，默认创建多设备协同数据库
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      // 多设备协同数据库：kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    };
    let store = await kvManager.getKVStore<distributedKVStore.SingleKVStore>('storeId', options)
    this.kvStore = store
  }
}

export let Db = new KVDb()