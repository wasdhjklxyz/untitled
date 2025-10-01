#include <linux/fs.h>
#include <linux/init.h>
#include <linux/module.h>

MODULE_LICENSE("GPL-2.0");

dev_t dev;
int nr_devs = 4;

static int hello_init(void)
{
	printk(KERN_ALERT "hello world\n");

	int ret = alloc_chrdev_region(&dev, MINOR(dev), nr_devs, "untitled");
	if (ret < 0) {
		printk(KERN_WARNING "Error: alloc_chrdev_region\n");
	}

	return ret;
}

static void hello_exit(void)
{
	unregister_chrdev_region(dev, nr_devs);

	printk(KERN_ALERT "goodbye\n");
}

module_init(hello_init);
module_exit(hello_exit);
