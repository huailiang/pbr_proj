using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Reflection;
using System;

using qtools.quv.pview;

namespace qtools.quv
{
	public class QUVWindow : EditorWindow
	{
		// STATIC
		[MenuItem ("Tools/QUVEditor")]	
		public static void ShowWindow () 
		{ 
			if (Resources.FindObjectsOfTypeAll<QUVWindow> ().Length > 0)
				return;

			QUVWindow window = (QUVWindow)ScriptableObject.CreateInstance<QUVWindow>();

            #if UNITY_5_1 || UNITY_5_2 || UNITY_5_3_OR_NEWER
            window.titleContent = new GUIContent("QUVEditor");
            #else
            window.title = "QUVEditor";
            #endif

			window.minSize = new Vector2(785, 473);
            window.wantsMouseMove = true;
			window.Show();
		}

		// PRIVATE
		private QUVMainView mainView;
		
		// CONSTRUCTOR
		void init()
		{			
			GUI.FocusControl(null);

			mainView = new QUVMainView(this);			

			Undo.undoRedoPerformed -= UndoRedoPerformed; 
			Undo.undoRedoPerformed += UndoRedoPerformed;
		}
		 
		// DESTRUCTOR
		public void OnDestroy()
		{
			Undo.undoRedoPerformed -= UndoRedoPerformed; 
            SceneView.onSceneGUIDelegate -= onSceneGUIDelegate;

            if (mainView != null) 
            {
                mainView.dispose();
			    mainView = null;
            }
        }

		// OVERRIDE
		void OnFocus() 
		{
			SceneView.onSceneGUIDelegate -= onSceneGUIDelegate;
			SceneView.onSceneGUIDelegate += onSceneGUIDelegate;
			OnSelectionChange();
        }

		void onSceneGUIDelegate(SceneView sceneView) 
		{
            if (mainView.onSceneGUIDelegate(sceneView))
                mainView.Repaint();
        }

        void OnGUI() 
		{
            if (mainView == null || !mainView.isInited()) init();		
            mainView.update((int)(position.width), (int)(position.height));
		}

		void OnSelectionChange() 
		{
			if (mainView == null) init();		
			else mainView.selectedGameObjectChanged();
		}

		public void UndoRedoPerformed()
		{
			if (mainView == null) init();
            else mainView.undoRedoPerformed();		
		}
	}
}