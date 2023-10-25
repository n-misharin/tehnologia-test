import java.io.*;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

public class UpdateClassFile {
    public static String[] CLASS_TEMPLATES = new String[]{
            "class", "interface"
    };

    public static class FileNameException extends Exception {
        public FileNameException(String message) {
            super(message);
        }
    }

    public static void main(String[] args) throws IOException, FileNameException {
        FileFilter classFileFilter = new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                return pathname.isFile() && pathname.getName().endsWith(".class");
            }
        };

        String baseDirectory = "task\\update";
        String targetDirectory = "task";

        for(File entryFile: getEntryFiles(baseDirectory, classFileFilter)){
            String newFilePath = targetDirectory + "\\" + classNameToPath(getClassNameByClassFile(entryFile));
            copyOrReplaceFile(entryFile, newFilePath);
            entryFile.delete();
        }
    }

    public static void createFileWithDirectories(String path) throws IOException {
        new File(path.substring(0, path.lastIndexOf("\\"))).mkdirs();
        File newFile = new File(path);
        newFile.createNewFile();
    }

    public static void copyOrReplaceFile(File srcFile, String path) throws IOException {
        File newFile = new File(path);
        if (newFile.exists()){
            newFile.delete();
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
        if (entryFiles != null){
            resultEntryFiles.addAll(Arrays.asList(entryFiles));
        }

        return resultEntryFiles;
    }

    public static String classNameToPath(String className) {
        return className.replace(".", "\\") + ".class";
    }

    public static String getClassNameByClassFile(File classFile) throws IOException, FileNameException {
        Process process = Runtime.getRuntime().exec("javap " + classFile.getPath());
        Scanner scanner = new Scanner(process.getInputStream());

        scanner.nextLine(); // read head
        String line = " " + scanner.nextLine();

        for (String s : CLASS_TEMPLATES) {
            String temp = " " + s + " ";
            if (line.contains(temp)) {
                return line.split(temp)[1].strip().split(" ")[0];
            }
        }
        throw new FileNameException("Class in file " + classFile.getPath() + " not found.");
    }
}
