import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatusEvent {
  String labelId;
  LoadStatus status;
  int cid;

  StatusEvent(this.labelId, this.status, {this.cid});
}

class RefreshStatusEvent {
  String labelId;
  RefreshStatus status;
  int cid;

  RefreshStatusEvent(this.labelId, this.status, {this.cid});
}

class LoadStatusEvent {
  String labelId;
  LoadStatus status;
  int cid;

  LoadStatusEvent(this.labelId, this.status, {this.cid});
}
