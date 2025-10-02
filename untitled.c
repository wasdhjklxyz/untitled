#include <linux/fs.h>
#include <linux/init.h>
#include <linux/module.h>

#include "untitled.h"

MODULE_LICENSE("GPL-2.0");

dev_t dev;
int nr_devs = 4;

static const struct file_operations fops = {
	.owner = THIS_MODULE,
	.llseek = generic_file_llseek,
	.read = untitled_read,
	.write = untitled_write,
	.open = untitled_open,
	.release = untitled_release,
};

ssize_t untitled_read(struct file *filp, char __user *buf, size_t count,
		      loff_t *pos)
{
	printk(KERN_DEBUG "untitled: read");
	return 0;
}

ssize_t untitled_write(struct file *filp, const char __user *buf, size_t count,
		       loff_t *pos)
{
	printk(KERN_DEBUG "untitled: write");
	return 0;
}

int untitled_open(struct inode *inode, struct file *filp)
{
	printk(KERN_DEBUG "untitled: open");
	return 0;
}

int untitled_release(struct inode *inode, struct file *filp)
{
	printk(KERN_DEBUG "untitled: release");
	return 0;
}

static int hello_init(void)
{
	printk(KERN_ALERT "hello world\n");

	int ret = alloc_chrdev_region(&dev, MINOR(dev), nr_devs, "untitled");
	if (ret < 0) {
		printk(KERN_WARNING "Error: alloc_chrdev_region\n");
	}

	// TODO: Wait for chrdev files to be created?
	return ret;
}

static void hello_exit(void)
{
	unregister_chrdev_region(dev, nr_devs);

	printk(KERN_ALERT "goodbye\n");
}

module_init(hello_init);
module_exit(hello_exit);
