class UsrList {
  String userName = "", deptName = "";

  UsrList({required this.deptName, required this.userName});

  get getUserName => this.userName;
  set setUserName(userName) => this.userName = userName;
  get getDeptName => this.deptName;
  set setToken(deptName) => this.deptName = deptName;
}
