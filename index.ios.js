/**
 * @providesModule movToMp4
 * @flow
 */
 import {
  NativeModules,
} from 'react-native';

var NativemovToMp4 = NativeModules.movToMp4;

var movToMp4 = {
convertMovToMp4: NativemovToMp4.convertMovToMp4,
removeConvertedVideo: NativemovToMp4.removeConvertedVideo,
checkDirectionExist: NativemovToMp4.checkDirectionExist,
};

export default movToMp4;
