import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.file.FileSystemException;
import java.util.ArrayList;
import java.util.Arrays;

public class UpdateClassFile {
    public static final int CLASS_FILE = 0xCAFEBABE;
    public static final int STRING_UTF_8 = 1;
    public static final int INTEGER = 3;
    public static final int FLOAT = 4;
    public static final int LONG = 5;
    public static final int DOUBLE = 6;
    public static final int CLASS = 7;
    public static final int STRING = 8;
    public static final int FIELD_REFERENCE = 9;
    public static final int METHOD_REFERENCE = 10;
    public static final int INTERFACE_METHOD_REFERENCE = 11;
    public static final int NAME_AND_DESCRIPTOR = 12;
    public static final int METHOD_DESCRIPTOR = 15;
    public static final int METHOD_TYPE = 16;
    public static final int INVOKE_DYNAMIC = 18;
    public static final int MODULE = 19;
    public static final int PACKAGE = 20;

    public static void main(String[] args) throws IOException, ClassNotFoundException {
        FileFilter classFileFilter = new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                return pathname.isFile() && pathname.getName().endsWith(".class");
            }
        };

        String baseDirectory = "task\\update";
        String targetDirectory = "task";

        for (File entryFile : getEntryFiles(baseDirectory, classFileFilter)) {
            String newFilePath = targetDirectory + "/" + classNameToPath(getClassNameByClassFile(entryFile));
            copyOrReplaceFile(entryFile, newFilePath);
            if (!entryFile.delete()) {
                System.out.printf("Не удалось удалить файл `%s`.", entryFile.getPath());
            }
        }
    }

    public static void createFileWithDirectories(String path) throws IOException {
        File directory = new File(path.substring(0, path.lastIndexOf("\\")));
        if (!directory.mkdirs()) {
            throw new FileSystemException("Failed to create directory `%s`.".formatted(directory));
        }
        File newFile = new File(path);
        if (!newFile.createNewFile()) {
            throw new FileSystemException("Failed to create file `%s`.".formatted(newFile.getPath()));
        }
    }

    public static void copyOrReplaceFile(File srcFile, String path) throws IOException {
        File newFile = new File(path);
        if (newFile.exists() && !newFile.delete()) {
            throw new FileSystemException("Failed to delete file `%s`.".formatted(srcFile));
        }
        createFileWithDirectories(newFile.getPath());
        copyFile(srcFile, path);
    }

    public static void copyFile(File srcFile, String path) throws IOException {
        File newFile = new File(path);
        FileChannel srcFileChannel = new FileInputStream(srcFile).getChannel();
        FileChannel newFileChannel = new FileOutputStream(newFile).getChannel();
        newFileChannel.transferFrom(srcFileChannel, 0, srcFileChannel.size());
        srcFileChannel.close();
        newFileChannel.close();
    }

    public static ArrayList<File> getEntryFiles(String pathToDirectory, FileFilter fileFilter)
            throws FileNotFoundException {

        File directory = new File(pathToDirectory);

        if (!directory.isDirectory() || !directory.exists()) {
            throw new FileNotFoundException("Directory " + directory.getAbsoluteFile() + " not found.");
        }

        ArrayList<File> resultEntryFiles = new ArrayList<>();

        File[] entryDirectories = directory.listFiles(new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                return pathname.isDirectory();
            }
        });

        if (entryDirectories != null) {
            Arrays.sort(entryDirectories);
            for (File entryDirectory : entryDirectories) {
                resultEntryFiles.addAll(getEntryFiles(entryDirectory.getPath(), fileFilter));
            }
        }

        File[] entryFiles = directory.listFiles(fileFilter);
        if (entryFiles != null) {
            resultEntryFiles.addAll(Arrays.asList(entryFiles));
        }

        return resultEntryFiles;
    }


    public static String getClassNameByClassFile(File classFile) throws IOException, ClassNotFoundException {
        FileInputStream fileInputStream = new FileInputStream(classFile);
        DataInputStream dataInput = new DataInputStream(fileInputStream);

        int magic = dataInput.readInt();

        if (magic != CLASS_FILE) {
            throw new ClassNotFoundException(
                    "The file `%s` is not exists class-file data.".formatted(classFile.getPath()));
        }

        dataInput.readInt(); // Read minor and major versions

        int constantPoolCount = dataInput.readUnsignedShort() - 1;

        String[] lines = new String[constantPoolCount];
        int[] constantsPool = new int[constantPoolCount];

        for (int i = 0; i < constantPoolCount; i++) {
            int tag = dataInput.readUnsignedByte();
            switch (tag) {
                case STRING_UTF_8:
                    // 2 bytes + x bytes - length and data
                    lines[i] = dataInput.readUTF();
                    break;
                case INTEGER:
                case FLOAT:
                case FIELD_REFERENCE:
                case METHOD_REFERENCE:
                case INTERFACE_METHOD_REFERENCE:
                case INVOKE_DYNAMIC:
                case NAME_AND_DESCRIPTOR:
                    // 4 bytes
                    dataInput.readInt();
                    break;
                case LONG:
                case DOUBLE:
                    // 8 bytes + 2 slots in pool
                    dataInput.readLong();
                    i++;
                    break;
                case CLASS:
                    // 2 bytes
                    constantsPool[i] = (dataInput.readShort() & 0xffff) - 1;
                    break;
                case STRING:
                case METHOD_TYPE:
                case MODULE:
                case PACKAGE:
                    //2 bytes
                    dataInput.readShort();
                    break;
                case METHOD_DESCRIPTOR:
                    // 3 bytes
                    dataInput.readByte();
                    dataInput.readShort();
                    break;
            }
        }

        dataInput.readUnsignedShort();// Read flags

        int thisClass = dataInput.readUnsignedShort() - 1;

        dataInput.close();

        return lines[constantsPool[thisClass]];
    }

    public static String classNameToPath(String className) {
        return className.replace(".", "\\") + ".class";
    }
}
