=====================================================================
�y��    �́z  HEdit060lzh TEditor �R���|�[�l���g ver 0.60
�y�o �^ ���z  HEdit060.lzh
�y�o�C�g���z  162,612 byte  
�y����Җ��z  �{�c���F (VYR01647)
�y�f�ڎҖ��z  �{�c���F (VYR01647)
�y������z  Windows95 + Delphi 2.0J or Delphi 3 or Delphi 4
�y�f�ڌ����z  1999/02/22
�y�쐬���@�z  LHA �ɂĉ�
�y�����L�[�z  1.%VYR01647 2.#FREE 3.#VCL 4.TEDITOR
�y����m�F�z  Windows95 + Delphi 2.0j and Delphi 3 and Delphi 4
�y�\�t�g��z  �t���[�E�F�A�R���|�[�l���g
�y�]�ڏ����z  ���R
=====================================================================
�y���e�Љ�z

�P�D�T�v
    �����̃G�f�B�^�R���|�[�l���g�ł��B
    �� �R�Q�j�̐���������܂���BWindows.pas ���J���܂��B
    �� �I��̈�̔w�i�F�E�O�i�F���w��o���܂��B
    �� �\��ꃊ�X�g��ێ����āA���̗\���̔w�i�F�E�O�i�F���w��o���܂��B
    �� Undo, Redo ���\�ł��B
    �� [EOF] �}�[�N�A���s�}�[�N�A�A���_�[���C����\���o���܂��B
    �� ���t�g�}�[�W���A�g�b�v�}�[�W���A�s�ԃ}�[�W���A�����Ԋu���w��
       �o���܂��B
    �� �P��ÂA�t�H���g�̐F�E�X�^�C����ς��ĕ\�����邱�Ƃ��\�ł��B
    �� �P�s������̃I�[�i�[�h���[���\�ł��B

    �� WordWrap ���o���܂��B
    
    �� �v���|�[�V���i���t�H���g�ɂ͑Ή����Ă��܂���B
       �ꉞ�\���o���܂����A����������܂���B(^^;)
    �� TCustomControl ����̔h���I�u�W�F�N�g�ł��̂ŁAEM_LINEFROMCHAR 
       �Ȃǂ� SendMessage ���Ă��m���炵�܂��B(^^;)
    
�Q�D�t�@�C���\��
    HEdit060.lzh �ɂ͈ȉ��̃t�@�C���������Ă��܂��B
    
    readme.txt ..... ���̃t�@�C��
    history.txt .... �o�[�W�����A�b�v����

    heditor2.dcu ... Delphi 2.0j �p�̃R���p�C���ς݃R���|�[�l���g�t�@�C��
    heditor3.dcu ... Delphi 3    �V
    heditor4.dcu ... Delphi 4    �V
                     
    �� ���C�u�����ɒǉ�����ۂ́A���g���� Delphi �̃o�[�W�����ɍ�����
       dcu �t�@�C���� HEditor.dcu �Ƀ��l�[�����Ă��g���������B
                      ^^^^^^^^^^^^^^^^^^^^^^
    heditreg.pas ... TEditor �R���|�[�l���g��o�^���邽�߂̃��j�b�g�t�@�C��
    heditreg.dcr ... �R���|�[�l���g�A�C�R���t�@�C��
    hstrprop.pas ... TStrings �v���p�e�B�G�f�B�^�BTEditor ��p�i�ύX�j
    hstrprop.dfm ... �v���p�e�B�G�f�B�^�̃t�H�[���t�@�C��
    hschfm.pas ..... �v���p�e�B�G�f�B�^���g�p����t�@�C��
    hschfm.dfm ..... �V
    hreplfm.pas .... �V
    hreplfm.dfm .... �V
    htsearch.pas ... �V
    project1.dpr ... �T���v���v���W�F�N�g
    project1.res ... �V
    unit1.pas ...... �V
    unit1.dfm ...... �V

    TEditor �𗘗p���� TStrings �v���p�e�B�G�f�B�^���t���Ă܂��B
    TEditor ��p�ɂȂ��Ă��܂����Aheditreg.pas ����
    RegisterPropertyEditor(
      TypeInfo(TStrings), nil, '', TStringsPropertyEditor);
    �Ƃ���ƁA���Ă� TStrings �Ɏg����悤�ɂȂ�܂��B
    Delphi �t���� TStrings �v���p�e�B�G�f�B�^��肩�Ȃ荂���ł��̂�
    �������������B(^^)v

    ���T���v���v���W�F�N�g���� Editor1.Lines �ɂ́AHEditor.pas �� 
    ��interface �����ێ�����Ă��܂��̂ŁA�����p�������B
    
    ���\�[�X�R�[�h�̌��J�͍l���Ă��܂���B�����I�ɂ̓V�F�A�E�F�A��
    �����邩������܂���B
    
�R�D���s���@
    LHA �ɂăf�B���N�g���W�J���𓀂����Ă������� ( LHA x HEdit060.lzh )

    HEditReg.pas, HEditReg.dcr, HEditor.dcu, HStrProp.pas, HStrProp.dfm
    HSchfm.pas, HSchfm.dfm, HReplfm.pas, HReplfm.dfm, HtSearch.pas
    
    �̂P�O�̃t�@�C�������C�u�����p�X�̒ʂ����t�H���_�ɃR�s�[������
    HEditReg.pas ���R���|�[�l���g�C���X�g�[�����ĉ������B
    ^^^^^^^^
    �u�v���p�e�B�G�f�B�^�Ȃ񂼗v���v�Ƃ�������
    HEditReg.pas, HEditReg.dcr, HEditor.dcu �̂R�̃t�@�C�����g�p����
    �������B���̏ꍇ HEditReg.pas ���̊Y�����i�Q�s�ځj���폜���ĉ������B
                                      ^^^^^^^^^^^^^^^^^^^^^^^^
�S�D����̃o�[�W�����A�b�v�̓��e
    ver 0.60 1999/02/22
    �EWordWrap �ɑΉ����܂����B
    �E�ڍׂ� history.txt ���Q�Ƃ��Ă��������B

�T�D����̉ۑ�
    �EWordWrap �̋@�\����
    �EEM_ �n���b�Z�[�W�n���h���̎���
    �E�h�L�������g�̐���(^^;) ���݃w���v�t�@�C�����쐬���ł��B
    �E���̑�

�U�D�ӎ�
  nifty:FDELPHI/MES/10 �ɂ����āA�����̂��ӌ������������A��ϊ��ӂ�������
  ���܂��B������F�l�̂��ӌ��A�����z�A���v�]�Ȃǂ�������������΍K���ł��B
  ��낵�����肢�v���܂��Bm(_ _)m

File Name�yHEdit060.lzh�z
=====================================================================