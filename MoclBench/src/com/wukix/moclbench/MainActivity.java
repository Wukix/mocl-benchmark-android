package com.wukix.moclbench;

import mocl.CL;
import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.Menu;

public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		// Initialize mocl
		// This only needs to be called once at start-up for any mocl app
		// (Inconsequential to performance. Takes 15ms on my Nexus 4)
		CL.cl_init();
		
		long start, elapsed;
		double ms;
		String result;
		
		// Run binary-trees as Java/Dalvik
		start = System.nanoTime();	
		result = BinaryTrees.run(16);
		elapsed = System.nanoTime() - start;
		ms = (double)elapsed / (double)1000000.0;
		Log.d("dalvik binary-trees result", result);
		Log.d("dalvik binary-trees time", ms + "ms");
		
		// Run binary-trees as Lisp/mocl
		start = System.nanoTime();
		result = CL.binary_trees(16);
		elapsed = System.nanoTime() - start;
		ms = (double)elapsed / (double)1000000.0;
		Log.d("mocl binary-trees result", result);
		Log.d("mocl binary-trees time", ms + "ms");		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
