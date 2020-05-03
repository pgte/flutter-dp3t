package me.pgte.dp3t_example

import org.dpppt.android.sdk.DP3T;
import org.dpppt.android.sdk.backend.models.ApplicationInfo;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstance: Bundle?) {
    super.onCreate(savedInstance)

    DP3T.init(
      this.getContext(),
      ApplicationInfo("dummy", "https://example.com", "https://example.com"))
  }
}
