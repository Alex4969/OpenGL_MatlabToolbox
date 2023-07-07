clear all

import javax.swing.JFrame

frame = JFrame("une Fenetre");
frame.setDefaultCloseOperation(frame.DISPOSE_ON_CLOSE);
frame.setSize(1280, 720);
frame.setLocationRelativeTo([]);
frame.setVisible(true);

viewer = Scene3D('GL4', frame);

%definition des objets

%affichage
viewer.Draw();

%suppression