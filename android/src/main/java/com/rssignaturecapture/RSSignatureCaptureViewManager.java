package com.rssignaturecapture;

import android.util.Log;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.bridge.ReactApplicationContext;
import com.rssignaturecapture.RSSignatureCaptureContextModule;


public class RSSignatureCaptureViewManager extends ViewGroupManager<RSSignatureCaptureMainView> {

	private RSSignatureCaptureContextModule mContextModule;

	public RSSignatureCaptureViewManager(ReactApplicationContext reactContext) {
		mContextModule = new RSSignatureCaptureContextModule(reactContext);
	}

	@Override
	public String getName() {
		return "RSSignatureView";
	}

	@Override
	public RSSignatureCaptureMainView createViewInstance(ThemedReactContext context) {
		Log.d("React"," View manager createViewInstance:");
		return new RSSignatureCaptureMainView(context, mContextModule.getActivity());
	}
}
