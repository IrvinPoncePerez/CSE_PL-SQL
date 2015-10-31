package touchesbegan.com.rastreomx;

import touchesbegan.com.rastreomx.R;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;

public class CotizaWebActivity extends Activity {
	private WebView wb;
	private String url;
	@SuppressLint("SetJavaScriptEnabled")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_cotiza_web);
		wb=(WebView)findViewById(R.id.webView1);	
		url = getIntent().getStringExtra("url");
		wb.loadUrl(url);
		wb.canScrollVertically(0);
		wb.zoomIn();
		wb.zoomOut();
		
		WebSettings webSettings = wb.getSettings();
		webSettings.setJavaScriptEnabled(true);
		
	}
}
