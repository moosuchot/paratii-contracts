pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract UserRegistry is Ownable {

    struct VideoInfo { // user-related information about this video
      bool isAcquired; // did the user buy this video?
      bool liked; // did the user like this video
      bool disliked; // did the user dislike this video
      uint256 _index; // index in the UserInfo.videosIndex
    }

    struct UserInfo {
      address _address;
      string name;
      string email;
      bytes32[] videoIndex; // the videos this user has seen
      mapping (bytes32 => VideoInfo) videos; // information about these vids
    }

    mapping (address=>UserInfo) public users;

    event LogRegisterUser(address _address, string _name, string _email);
    event LogUnregisterUser(address _address);
    event LogLikeVideo(address _address, string _videoId, bool _liked);

    modifier onlyOwnerOrUser(address _address) {
      require(msg.sender == owner || msg.sender == _address);
      _;
    }

    function UserRegistry() {
        owner = msg.sender;
    }

    function registerUser(address _userAddress, string _name, string _email) onlyOwnerOrUser(_userAddress) {
      bytes32[] memory emptyIndex;
      users[_userAddress] =  UserInfo({
          _address: _userAddress,
          name: _name,
          email: _email,
          videoIndex: emptyIndex
      });

      LogRegisterUser(_userAddress, _name, _email);
    }

    function unregisterUser(address _userAddress) public onlyOwnerOrUser(_userAddress) {
        delete users[_userAddress];
    }

    function getUserInfo(address _userAddress) constant returns(string, string) {
      UserInfo storage userInfo = users[_userAddress];
      return (userInfo.name, userInfo.email);
    }

    /* like/dislike a video.
     * @param like If true, register a like, if false, register a dislike
     */
    function likeVideo(string _videoId, bool _liked) {
      address _userAddress = msg.sender;
      VideoInfo storage video = users[_userAddress].videos[sha3(_videoId)];

      // if the video is not known yet
      if (video._index == 0) {
        video._index = users[_userAddress].videoIndex.push(sha3(_videoId));
        users[_userAddress].videos[sha3(_videoId)] = video;
      }

      if (_liked) {
        video.liked = true;
        video.disliked = false;
      } else {
        video.liked = false;
        video.disliked = true;
      }

      LogLikeVideo(_userAddress, _videoId, _liked);
    }

    function userLikesVideo(address _userAddress, string _videoId) constant returns(bool) {
      return users[_userAddress].videos[sha3(_videoId)].liked;
    }

    function userDislikesVideo(address _userAddress, string _videoId) constant returns (bool) {
      return users[_userAddress].videos[sha3(_videoId)].disliked;
    }
}
